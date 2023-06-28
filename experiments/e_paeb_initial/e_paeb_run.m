function  e_paeb_run(params)
%E_PAEB_RUN run pedestrian aeb experiment in matlab experiment manager

    ia_drivingScenario.initialSpeed(params.initialSpeed);
    ia_drivingScenario.inExperiment(true); % some code won't run right in an experiment

    % this is the driving scenario function exported from the DSD
    % modified to invoke our version of driving scenario.
    initialPAEBTest();

end

