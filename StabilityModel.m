classdef StabilityModel < handle
    % Simple model of standing postural stability, consisting of foot and
    % body segments, and two muscles that create moments about the ankles,
    % tibialis anterior and soleus. 
    
    methods (Static)
        function result = soleusLength(theta)
            % Soleus length as a function of ankle angle. 
            % 
            % theta: body angle (up from prone horizontal)
            % result: soleus length
            
            origin = zeros(2,length(theta));
            for i = 1:length(theta) %this loop optionally handles a list of theta 
                origin(:,i) = [cos(theta(i)) -sin(theta(i)); sin(theta(i)) cos(theta(i))]*[.3; .03];                
            end
            insertion = [-.05; -.02]; 
            difference = origin - insertion;
            result = (difference(1,:).^2 + difference(2,:).^2).^.5;
            
            % return result with same shape as theta
            if size(theta, 1) > size(theta, 2)
                result = result';
            end
        end
        
        function result = tibialisLength(theta)
            % Soleus length as a function of ankle angle. 
            % 
            % theta: body angle (up from prone horizontal)
            % result: tibialis anterior length
            
            origin = zeros(2,length(theta));
            for i = 1:length(theta)
                origin(:,i) = [cos(theta(i)) -sin(theta(i)); sin(theta(i)) cos(theta(i))]*[.3; -.03];  
            end
            insertion = [.06; -.03];
            difference = origin - insertion;
            result = (difference(1,:).^2 + difference(2,:).^2).^.5;

            % return result with same shape as theta
            if size(theta, 1) > size(theta, 2)
                result = result';
            end
        end        
        
        function simulate(control, T)
            % Runs a simulation of the model and plots results. 
            % 
            % control: 0 means no control law should be usd to stabilize
            %   the model; 1 means a control law should be used
            % T: total time to simulate, in seconds
            
            restLengthS = StabilityModel.soleusLength(pi/2);
            restLengthTA = StabilityModel.tibialisLength(pi/2);
            
            S = HillTypeMuscle(16000, .6*restLengthS, .4*restLengthS);
            TA = HillTypeMuscle(2000, .6*restLengthTA, .4*restLengthTA);
            
            OPTIONS = odeset('AbsTol', 1e-6, 'RelTol', 1e-5);  % use this as the final argument to ode45

            dS = .05;
            dTA = .03;
            
            theta0 = pi/2;
                        
            odefun = @(t, x) dynamics(t, x, S, TA, control);            
            [time, x] = ode45(odefun, [0 T], [theta0 0 1 1], OPTIONS);

            fS = getForce(S, StabilityModel.soleusLength(x(:,1)), x(:,3));
            fTA = getForce(TA, StabilityModel.tibialisLength(x(:,1)), x(:,4));

            subplot(2,1,1), plot(time, x(:,1))
            set(gca, 'FontSize', 18)
            ylabel('Body Angle (rad)')
            subplot(2,1,2), hold on
            plot(time, fS*dS, 'r');
            plot(time, -fTA*dTA, 'g');
            plot(time, getGravityMoment(x(:,1)), 'k')
            legend('soleus', 'tibialis', 'gravity')
            set(gca, 'FontSize', 18)
            xlabel('Time (s)')
            ylabel('Torques (Nm)')
        end        
    end
end

function dx_dt = dynamics(t, x, S, TA, control) 
    % Right-hand side of the dynamic equation of the model. 
    % 
    % t: time of current step (s)
    % x: model state: [ankle angle, angular velocity, soleus CE length, TA
    %   CE length]
    % S: soleus muscle object (a HillTypeModel)
    % TA: tibialis anterior muscle object (a HillTypeModel)
    
    t
    
    Iankle = 90;
    dS = .05;
    dTA = .03;

    %WRITE CODE HERE TO IMPLEMENT THE MODEL DYNAMICS
    

end

function result = getGravityMoment(angle)
    % angle: angle of body segment (up from horizontal)
    % result: moment about ankle due to force of gravity on body
    
    m = 75; % body segment mass 
    lCOM = 1; % distance from ankle to body segment centre of mass
    g = 9.81; 
    result = m*g*lCOM*sin(angle-pi/2);
end

