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

            % First we show where we are (were)
            piWrite(scenario.roadData.recipe);
            scene = piRender(scenario.roadData.recipe);
            scene = piAIdenoise(scene, 'quiet', true, 'interleave', true);

            % add to our scene list
            scenario.sceneList{end+1} = scene;
            scene = sceneSet(scene, 'display mode', 'hdr');
            sceneWindow(scene);

            % Here we want to create a movie/video
            % presumably one frame at a time
            [image, detectionResults] = scenario.imageAndDetect(scene);
            addToVideo(scenario, scene, image);

            % This might be more current
            ourTimeStep = scenario.SampleTime;

            % Move Actors based on their velocity
            % e.g. both the egoVehicle & the lookAt from/to
            % Assume that egoVehicle is #1
            for ii = 1:numel(scenario.roadData.actorsIA)
                ourActor = scenario.roadData.actorsIA{ii};
                if ourActor.hasCamera
                    egoVelocity = scenario.roadData.actorsDS{ii}.Velocity;
                    % Move camera
                    adjustedVelocity = egoVelocity .* [-1 -1 0];
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
