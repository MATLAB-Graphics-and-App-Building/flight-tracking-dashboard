classdef tFlightDashboardApp < matlab.unittest.TestCase

    methods ( Test )

        function tAppLaunchesWithNoWarnings( testCase )

            testCase.fatalAssertWarningFree( @launchApp, ...
                "Launching the FlightDashboardApp was not warning-free." )

            function launchApp()

                FD = FlightDashboardApp();
                appCleanup = onCleanup( @() delete( FD ) );

            end % launchApp

        end % tAppLaunchesWithNoWarnings

    end % methods ( Test )

end % classdef