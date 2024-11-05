% quick check if the b spline approximations are oscillatting perhaps too
% much, and makes figures for the plots if they are. 

%% First load data
T = readtable("ProcessedData.csv");
% transform the game_id to categorical. Allows efficient manipulation of the table data
T.game_id = categorical(T.game_id);
games = categories(T.game_id);
numgames = length(games);


%% load in splines 

load("UniformSplines.mat");


numties = 0;
% Spline check is here
for i = 1:numgames
     gamedata = T(T.game_id == games(i),:);

     dotheplot = false; 
     plottitle = "Spline: " + num2str(i);

    % Check 1, potentially oscillating a lot
    if any(abs(splines(i).coefs) > 1.5) || any(isnan(splines(i).coefs))
        %maybe oscillating too much or something else is wrong
        dotheplot = true; 
    end

    % Check 2, see if there is any large gap in the data. Ignore small
    % datasets
    t = sort(gamedata.game_seconds_remaining);
    gamediff = t(2:end) - t(1:(end-1));
    if max(gamediff) > 250 && length(gamedata.game_seconds_remaining) > 60
         %plot spline after loading them
         dotheplot = true; 
         plottitle = plottitle + " Large Data Gap of " + num2str(max(gamediff));           
    end

    if any(splines(i).knots > 3600)
        dotheplot = true;
        plottitle = plottitle + " Exceeds the domain";
    end

    %check tie games 
    if gamedata.home_wp(end) == 0.5
        dotheplot = true;
        plottitle = [plottitle, "Tie Game"];
        numties = numties + 1;
    end
    
    if dotheplot
        figure; fnplt(splines(i)); 
        hold on 
        plot(gamedata.game_seconds_remaining,gamedata.home_wp,'.');
        hold off
        title(plottitle);
    end
end