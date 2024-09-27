% constants and parameters
clear;
% load data
T = readtable("NFL2023season_win_prob.csv");
T = rmmissing(T);
flipgames = true; 

% transform the game_id to categorical.
% Allows efficient manipulation of the table data
T.game_id = categorical(T.game_id);

%get list of all games_ids
games = categories(T.game_id);
numgames = length(games);

%iterate through the played games and clean up the overtime data overtime data is rescaled so that all games are "played" from 0 to 3600 so they can be compared effectively
for i = 1:numgames
  gamedata = T(T.game_id == games(i),:);
  zero_index = find(gamedata.game_seconds_remaining == 0);
  % if the first index occurs before the length of the array that means we have overtime to account for. Rescale all data so its between 3600 and 0.
  if zero_index(1) < length(gamedata.game_seconds_remaining)
    overtime_seconds = gamedata.game_seconds_remaining(zero_index(1)+1); % hope that this works
    gamedata.game_seconds_remaining(zero_index(1)+1:end) = gamedata.game_seconds_remaining(zero_index(1)+1:end) - overtime_seconds;
    overtime_total = gamedata.game_seconds_remaining(zero_index(1)+1) - gamedata.game_seconds_remaining(end);
    %shift back to positives and rescale back to 3600 to 0
    gamedata.game_seconds_remaining = 3600/(3600+overtime_total)*(gamedata.game_seconds_remaining - gamedata.game_seconds_remaining(end));
  end
  %change data to run from 0 to 3600 instead of 3600 to 0 for convenience
  gamedata.game_seconds_remaining = 3600 - gamedata.game_seconds_remaining;
  
  %Set repeat time values to NaN for later removal
  [~,index,~] = unique(gamedata.game_seconds_remaining,'stable');
  tmp = nan(size(gamedata.game_seconds_remaining));
  tmp(index) = gamedata.game_seconds_remaining(index);
  gamedata.game_seconds_remaining = tmp;
  %overwrite old data with new processed data
  T(T.game_id == games(i),:) = gamedata;
end
T = rmmissing(T);


% Flip the games so that we are always plotting the loser 
is_game_flipped = zeros(numgames,1);
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

%generate the correlation matrices

correlation_dtw = zeros(numgames,numgames);

%correlation is symmetric so only compute the strictly upper-triangular
for i = 1:numgames
  gamedata1 = T(T.game_id == games(i),:);
  for j = i+1:numgames
    gamedata2 = T(T.game_id == games(j),:);
    correlation_dtw(i,j) = dtw(gamedata1.home_wp,gamedata2.home_wp);
  end
end

% copy the upper to the lower
correlation_dtw = correlation_dtw + correlation_dtw';


writematrix(correlation_dtw,"correlation_dtw.csv");
