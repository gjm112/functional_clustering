% constants and parameters
clear;
H1_weight = 1e3;
use_optimal_knots = true; % for the cluster center algorithms assumes this
                           % is true for now!!! 
flipgames = true; 

% load data
T = readtable("nfl-pbp-data-1999-2023.csv");
T = rmmissing(T);

% transform the game_id to categorical. Allows efficient manipulation of the table data
T.game_id = categorical(T.game_id);

%get list of all games_ids
games = categories(T.game_id);
numgames = length(games);
numpoints = zeros(numgames,1);

overtime_game = false(numgames,1);
nonordered_data = false(numgames,1);

%iterate through the played games and create meta-data  and clean up the overtime data overtime data is rescaled so that all games are "played" from 3600 to 0 so they can be compared effectively

for i = 1:numgames
  gamedata = T(T.game_id == games(i),:);
  zero_index = find(gamedata.game_seconds_remaining == 0);
  % if the first index occurs before the length of the array that means we have overtime to account for. Rescale all data so its between 3600 and 0.
  if ~isempty(zero_index) && zero_index(1) < length(gamedata.game_seconds_remaining)
      %finding the index for where overtime starts
      if length(zero_index) == 1
          overtime_index = zero_index(1);
      elseif zero_index(end) == length(gamedata.game_seconds_remaining)
          overtime_index = zero_index(end-1);
      else
          overtime_index = zero_index(end);
      end
    
      % check if actually have overtime
      if overtime_index < length(gamedata.game_seconds_remaining)
         %mark overtime for removal
         gamedata.home_wp(overtime_index+1:end) = nan;
         gamedata.game_seconds_remaining(overtime_index+1:end) = 0;
         overtime_game(i) = true;
      end
  end

  %change data to run from 0 to 3600 instead of 3600 to 0 for convenience of using b-splines and integration
  gamedata.game_seconds_remaining = 3600 - gamedata.game_seconds_remaining;

  %Set repeat time values to NaN for later removal
  [~,index,~] = unique(gamedata.game_seconds_remaining,'stable');
  tmp = nan(size(gamedata.game_seconds_remaining));
  tmp(index) = gamedata.game_seconds_remaining(index);
  gamedata.game_seconds_remaining = tmp;

  %overwrite old data with new processed data
  T(T.game_id == games(i),:) = gamedata;
  
  numpoints(i) = length(index);
end
T = rmmissing(T);

% now pass through and remove games with unordered data

% Note: this ends up removing 44 games (there were 51 games with unordered data,
% but 7 of these only have unordered data in their overtime, so aren't
% removed here). 

for i = 1:numgames
    gamedata = T(T.game_id == games(i),:);
    nonordered_data(i) = ~issorted(gamedata.game_seconds_remaining,'ascend');
    if nonordered_data(i) 
        % mark game for removal
        gamedata.game_seconds_remaining(:) = nan;
        T(T.game_id == games(i),:) = gamedata;
    end
end
T = rmmissing(T);

% adjust indices for after game removal
overtime_game = overtime_game(~nonordered_data);
numpoints = numpoints(~nonordered_data);

%redo categories as some games are gone
T.game_id = categorical(T.game_id,unique(T.game_id));
games = categories(T.game_id);
numgames = length(games);

minpoints = min(numpoints);

% Flip the games so that we are always plotting the loser 
is_game_flipped = false(numgames,1);
if flipgames
    for i = 1:numgames
        gamedata = T(T.game_id == games(i),:);
        if gamedata.home_wp(end) > 0.9
            % home team won, so flip home and away
            gamedata.home_wp = 1-gamedata.home_wp;
            is_game_flipped(i) = true;
            %overwrite old data with new processed data
            T(T.game_id == games(i),:) = gamedata;
        end
    end
end

% With this we can generate a set of knots for the b-spline

order = 4; %4 means cubic
order_other = 3;
point_ratio = 0.2;
finer_point_ratio = 0.3;
small_number_points_threshold = 60;
max_diff_threshold = 250;
super_max_diff_threshold = 500;
knots = linspace(0,3600,floor(point_ratio*minpoints));

% generate the b-spline least-square approximations

if use_optimal_knots
  for i = 1:numgames
    gamedata = T(T.game_id == games(i),:);
    numpoints = length(gamedata.game_seconds_remaining);
    t = sort(gamedata.game_seconds_remaining);
    maxdiff = max(t(2:end) - t(1:(end-1)));
    if maxdiff > super_max_diff_threshold
        splines(i) = spap2(floor(finer_point_ratio*numpoints),2,gamedata.game_seconds_remaining,gamedata.home_wp);
    elseif numpoints < small_number_points_threshold || maxdiff > max_diff_threshold
        splines(i) = spap2(floor(finer_point_ratio*numpoints),order_other,gamedata.game_seconds_remaining,gamedata.home_wp);
    else
        splines(i) = spap2(floor(point_ratio*numpoints),order,gamedata.game_seconds_remaining,gamedata.home_wp);
    end
  end
else
    for i = 1:numgames
    gamedata = T(T.game_id == games(i),:);
    splines(i) = spap2(augknt(knots,order),order,gamedata.game_seconds_remaining,gamedata.home_wp);
  end
end


%generate the correlation matrices

correlation_L2 = zeros(numgames,numgames);
correlation_H1 = zeros(numgames,numgames);
tic
%correlation is symmetric so only compute the strictly upper-triangular
for i = 1:numgames
  for j = i+1:numgames
    tmp = fncmb(splines(i),'-',splines(j));
    tmp_der = fnder(tmp);
    l2_spline = fncmb(tmp,'*',tmp);
    h1_spline = fncmb(tmp_der,'*',tmp_der);
    correlation_L2(i,j) = sqrt(diff(fnval(fnint(l2_spline),[0,3600])));
    correlation_H1(i,j) = sqrt(correlation_L2(i,j).^2 + H1_weight*diff(fnval(fnint(h1_spline),[0,3600])));
  end
end
toc
% copy the upper to the lower   
correlation_L2 = correlation_L2 + correlation_L2';
correlation_H1 = correlation_H1 + correlation_H1';

writematrix(correlation_H1,"cor_H1_no_overtime.csv");
writematrix(correlation_L2,"cor_L2_no_overtime.csv");
writematrix(is_game_flipped,"is_game_flipped_no_overtime.csv");
writematrix(overtime_game, "overtimegame_no_overtime.csv")
writecell(games,"gamenames_no_overtime.csv");
writetable(T,"ProcessedData_no_overtime.csv");
% Save splines
save("Splines_no_overtime.mat","splines");
%save the unordered gamenames that were removed 
writecell(games(nonordered_data),"gamenames_unordered.csv");

%% How to plot a game
%T.game_id = categorical(T.game_id);  %only 1 time needed
%gamedata = T(T.game_id == games(i),:); %the game i you want to plot
%plot(gamedata.game_seconds_remaining,gamedata.home_wp)