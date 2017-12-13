classdef stateV1
    properties
        casename
        x
        dxdt
        parameters % struct, contains sizes, structure, and dynamic information
        vmpc % virtual mpc, include each generator as a node
    end
    
    methods
        function S = stateV1(casename)
            if ischar(casename)
                S.casename = casename;
                mpc = loadcase(casename);
                [S.x, S.parameters, S.vmpc] = S.initiate_state(mpc);
                % solve the initial state
                f_x = @(x) S.fx(0,x);
                [S.x,~]=fsolve(f_x,S.x);
                S.dxdt = fx(S,0,S.x);
            elseif isa(casename,'stateV1')
                S = casename;
            else
                if isstruct(casename)
                    mpc = casename;
                    [S.x, S.parameters, S.vmpc] = S.initiate_state(mpc);
                    % solve the initial state
                    f_x = @(x) S.fx(0,x);
                    [S.x,~]=fsolve(f_x,S.x);
                    S.dxdt = fx(S,0,S.x);
                else
                    error('Invalid case name');
                end
            end
        end
        
        function display(S)
            disp(['stateV1:' S.casename]);
            disp(['Buses: ' num2str(S.parameters.nb)...
                '; Generators: ' num2str(S.parameters.ng)...
                '; Lines:' num2str(S.parameters.nl)...
                '; x dimension:' num2str(length(S.x))]);
        end
        
        % dynamic fuctions
        dxdt = fx(S,t,x); % dynamic function
        [T1, Y1] = solve_dynamic(S,tf);
        
        
        % auxilliary functions
        [w,ga,ba,eita] = unpack_x(S,x); % to facilitate take derivative and other calculations
        [nb,ng,nl,Bij,Cij,Pg,Pl,Dg,Dl,Mg,Tl] = unpack_parameters(S)
        
        
        % power flow, and corresponding energy on lines
        [fv,fl] = power_flow(S,x);% dictionary {(i,j):Pf}, flow virtual and real lines
        [Ev,El] = power_flow_energy(S,x);
        
        
        % lypanov functions
        l = lyapunov_energy(S,x);
        g = grad_lyapunov(S,x);
        [g,err] = numeric_grad_lyapunov(S,x);
        H = hessian_lyapunov(S,x);% Hessian = jacobian(grad(lyapunov))
        H = numeric_hessian_lyapunov(S,x);% numeric estimate using lyapunov energy
        M = skew_matrix(S);
        J = jacobian_f(S,x);% J = df/dx = M*Hessian
        
        
        % find fixed points from different initial states
        x_star = fixed_points_nearby(S,x0);
        
        % output the information of the state
        elist = edge_list(S);% container{'from','to'}, meanwhile print out virtual lines, real lines,
        
        % adjust the state by user
        new_x = turn_off_lines(S,e1);%e1=[from to]
        x = pack_x(S,w,ga,ba,eita);
        
        % adjust the parameters by user
        new_para = change_parameters(S, dName, dValue);
    end
    
    
    methods (Static = true, Access = private)
        [x, parameters, vmpc] = initiate_state(mpc);
    end
    
    methods (Static = true)
        theta_x = onoff(beta);
        Theta_x = onoff_energy(beta);
    end
    
    
end