% quick check if the b spline approximations are oscillatting perhaps too
% much, and makes figures for the plots if they are. Assumes the workspaxe
% of BSplineVersion is available

for i = 1:numgames
    if any(abs(splines(i).coefs) > 1.1)
        %maybe oscillating too much? 
        disp(i)
        figure; fnplt(splines(i)); 
        hold on 

        gamedata = T(T.game_id == games(i),:);
        plot(gamedata.game_seconds_remaining,gamedata.home_wp,'.');
        hold off
        title("Spline: " + num2str(i));
    end
end
        