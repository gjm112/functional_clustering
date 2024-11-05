clc
clear
 
%quick removal scrip, removes tie game data
shouldsave = false;

%% First load data
T = readtable("ProcessedData.csv");

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");

is_game_flipped = readmatrix("is_game_flipped.csv");

% transform the game_id to categorical. Allows efficient manipulation of the table data
T.game_id = categorical(T.game_id);
games = categories(T.game_id);
numgames = length(games);

%% load in splines 

load("UniformSplines.mat");

istie = false(numgames,1);

for i = 1:numgames
     gamedata = T(T.game_id == games(i),:);
    if gamedata.home_wp(end) == 0.5
       istie(i) = true;
    end
end

% remove tie games 

tiegames = games(istie);
games = games(~istie);

tiesplines = splines(istie);
splines = splines(~istie);

is_game_flipped = is_game_flipped(~istie);

cor_tie_l2 = cor_l2(istie,:);
cor_tie_h1 = cor_h1(istie,:);

cor_l2 = cor_l2(~istie,~istie);
cor_h1 = cor_h1(~istie,~istie);

% overwrite previous results 
if shouldsave
    writematrix(cor_h1,"correlation_H1.csv");
    writematrix(cor_l2,"correlation_L2.csv");
    writematrix(is_game_flipped,"is_game_flipped.csv");
    writecell(games,"gamenames.csv");
    % Save splines
    save("UniformSplines.mat","splines");

    save("TieSplines.mat","tiesplines");
    writematrix(cor_tie_h1,"correlation_H1_ties.csv");
    writematrix(cor_tie_l2,"correlation_L2_ties.csv");
    writecell(games,"gamenames_ties.csv");
end