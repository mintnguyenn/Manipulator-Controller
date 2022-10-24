function controlURRobot()

    jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2);
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
% 
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.
durationSeconds = 5; % This is how many seconds the movement will take
% 
startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
%       
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
% nextJointState_123456 = currentJointState_123456 + [0,pi/8,-pi/8,0,0,pi/8];
endJointSend.Positions = [-pi/4, -pi/3, pi/2, 0, 0, 0];
% endJointSend.Positions = [0, -pi/2, 0, -pi/2, 0, 0];
% endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);
% 
goal.Trajectory.Points = [startJointSend; endJointSend];
pause(1);
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);
end