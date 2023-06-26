function  e_paeb_run(params)
%E_PAEB_RUN run pedestrian aeb experiment in matlab experiment manager

    
    % Try setting as a static for ia_drivingScenario()
    ia_drivingScenario.initialSpeed(params.initialSpeed);

    % this is the driving scenario function exported from the DSD
    % modified to invoke our version of driving scenario.
    initialPAEBTest();

end

