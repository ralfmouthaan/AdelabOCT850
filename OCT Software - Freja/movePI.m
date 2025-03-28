function newPos = movePI(PIdevice,commandedPosition,ax)
% Move Stage to

% if nargin<3
%     ax = '1';
% end

% determine the allowed travel range of the stage
minimumPosition = PIdevice.qTMN ( ax );
maximumPosition = PIdevice.qTMX ( ax );
travelRange = ( maximumPosition - minimumPosition );

if (commandedPosition - minimumPosition) <= travelRange
    PIdevice.MOV ( ax, commandedPosition );
    
    disp ( 'Stage is moving')
    % wait for motion to stop
    while(0 ~= PIdevice.IsMoving ( ax ) )
        pause ( 0.1 );
        fprintf('.');
    end    
    newPos = PIdevice.qPOS(ax);
    disp('Reached!')
end
end