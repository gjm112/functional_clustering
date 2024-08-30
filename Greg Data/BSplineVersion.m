% constants and parameters
clear;
H1_weight = 1e3;

% load data
T = readtable("NFL2023season_win_prob.csv");
T = rmmissing(T);

% transform the game_id to categorical. Allows efficient manipulation of the table data
T.game_id = categorical(T.game_id);

%get list of all games_ids
games = categories(T.game_id);
numgames = length(games);
numpoints = zeros(numgames,1);

%iterate through the played games and create meta-data  and clean up the overtime data overtime data is rescaled so that all games are "played" from 3600 to 0 so they can be compared effectively

for i = 1:numgames
  gamedata = T(T.game_id == games(i),:);
  zero_index = find(gamedata.game_seconds_remaining == 0);
  % if the first index occurs before the length of the array that means we have overtime to account for. Rescale all data so its between 3600 and 0.
  if zero_index(1) < length(gamedata.game_seconds_remaining)
    overtime_seconds = gamedata.game_seconds_remaining(zero_index(1)+1); % hope that this works
    gamedata.game_seconds_remaining(zero_index(1)+1:end) = gamedata.game_seconds_remaining(zero_index(1)+1:end) - overtime_seconds;
    overtime_total = gamedata.game_seconds_remaining(zero_index(1)+1) - gamedata.game_seconds_remaining(end);
    %shift back to positives and rescale back to 3600 to 0
    gamedata.game_seconds_remaining = 3600/(3600+overtime_total)*(gamedata.game_seconds_remaining + overtime_total);
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
minpoints = min(numpoints);

% With this we can generate a set of knots for the b-spline

order = 4; %4 means cubic
knots = linspace(0,3600,floor(0.7*minpoints));

% generate the b-spline least-square approximations
for i = 1:numgames
  gamedata = T(T.game_id == games(i),:);
  splines(i) = spap2(augknt(knots,order),order,gamedata.game_seconds_remaining,gamedata.home_wp);
end

%generate the correlation matrices

correlation_L2 = zeros(numgames,numgames);
correlation_H1 = zeros(numgames,numgames);

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

% copy the upper to the lower
correlation_L2 = correlation_L2 + correlation_L2';
correlation_H1 = correlation_H1 + correlation_H1';

writematrix(correlation_H1,"correlation_H1.csv");
writematrix(correlation_L2,"correlation_L2.csv");