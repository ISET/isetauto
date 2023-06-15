        %% Simulation turn advance 
        function running = advance(scenario)

            % Need to place vehicles and actors now that we hopefully have yaw data
            % Just do this once:
            if scenario.needToPlaceVehicles == true
                scenario.placeVehicles();
                scenario.needToPlaceVehicles = false;
            end
            if scenario.needToPlaceActors == true
                scenario.placeActors();
                scenario.needToPlaceActors = false;
            end

            % Set our interval for use in computing motion
            ourTimeStep = scenario.SampleTime;

            % First we show where we are (were)
            piWrite(scenario.roadData.recipe);
            scene = piRender(scenario.roadData.recipe);
            if scenario.deNoise == true
                scene = piAIdenoise(scene,'quiet', true, 'batch', true);
            end

            % add to our scene list for logging
            scenario.sceneList{end+1} = scene;

            % show preview if desired
            if scenario.previewScenes
                scene = sceneSet(scene, 'display mode', 'hdr');
                sceneWindow(scene);
            end

            % Create an image with a camera, and run a detector on it
            [image, scenario.detectionResults] = scenario.imageAndDetect(scene);

            % Here we want to create a movie/video
            % presumably one frame at a time
            addToVideo(scenario, scene, image);

            % Move Actors based on their velocity
            % e.g. both the egoVehicle & the lookAt from/to
            % Assume that egoVehicle is #1
            for ii = 1:numel(scenario.roadData.actorsIA)
                ourActor = scenario.roadData.actorsIA{ii};
                if ourActor.hasCamera
                    egoVelocity = scenario.roadData.actorsDS{ii}.Velocity;

                    % if we have a pedestrian, begin braking
                    if scenario.detectionResults.foundPed
                        fprintf('found ped\n');
                        % braking should move closer to abs()
                        % for now just decelerate in forward/back
                        if ourActor.velocity(1) < 0
                            % negativeVelocity = true;
                            ourActor.velocity(1) = ...
                            ourActor.velocity(1) - ourActor.brakePower(1);
                        else
                            % negativeVelocity = false;
                            ourActor.velocity(1) = ...
                            ourActor.velocity(1) + ourActor.brakePower(1);
                        end

                        ourActor.velocity(1) = ...
                            max(ourActor.velocity(1) - ...,
                            0);
                    end

                    % Move camera
                    adjustedVelocity = ia_drivingScenario.dsToIA(egoVelocity);
                    scenario.roadData.recipe.lookAt.from = ...
                        scenario.roadData.recipe.lookAt.from + ...
                        (adjustedVelocity .* ourTimeStep);
                end
                % Also move our Actors by time step * velocity
                fprintf("DSVelocity for %s : %2.1f, %2.1f, %2.1f\n", ...
                    scenario.roadData.actorsDS{ii}.Name, ...
                    scenario.roadData.actorsDS{ii}.Velocity(1), ...
                    scenario.roadData.actorsDS{ii}.Velocity(2), ...
                    scenario.roadData.actorsDS{ii}.Velocity(3));
                fprintf("DSyaw for %s : %2.1f\n", ...
                    scenario.roadData.actorsDS{ii}.Name, ...
                    scenario.roadData.actorsDS{ii}.Yaw);
                % move asset per velocity inherited from DS
                ourActor.moveAsset(scenario, ...
                    scenario.roadData.actorsDS{ii});
            end

            % Then determine whether braking & subtract from Velocity
            % (We can't just subtract from speed, as it has been broken
            % into velocity components already based on waypoints
            % In this case we also need to modify the SDS version of
            % Velocity

            % run super-class method
            running = advance@drivingScenario(scenario);
        end
