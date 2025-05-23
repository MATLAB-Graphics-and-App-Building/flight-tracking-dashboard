classdef AircraftChart < matlab.graphics.chartcontainer.ChartContainer
    %AIRCRAFTCHART Custom chart for displaying a 3D rendering of an
    %aircraft. The chart also provides roll, pitch and yaw methods for
    %modifying the attitude of the aircraft.

    properties
        % Aircraft triangulation coordinate data.
        Triangulation(:, 3) triangulation = defaultAircraft()
    end % properties

    properties ( Access = private )
        % Chart axes.
        Axes(:, 1) matlab.graphics.axis.Axes {mustBeScalarOrEmpty}
        % Transform object.
        Transform(:, 1) matlab.graphics.primitive.Transform ...
            {mustBeScalarOrEmpty}
        % Patch object for the aircraft.
        Patch(:, 1) matlab.graphics.primitive.Patch {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = AircraftChart( namedArgs )

            arguments ( Input )
                namedArgs.?AircraftChart
            end % arguments

            % Call the superclass constructor.
            f = figure( "Visible", "off" );
            figureCleanup = onCleanup( @() delete( f ) );
            obj@matlab.graphics.chartcontainer.ChartContainer( ...
                "Parent", f )
            obj.Parent = [];
            
            % Set any user-defined properties.
            set( obj, namedArgs )

        end % constructor

        function roll( obj, theta )

            obj.rotate( "roll", theta )

        end % roll

        function pitch( obj, theta )

            obj.rotate( "pitch", theta )

        end % pitch

        function yaw( obj, theta )

            obj.rotate( "yaw", theta )

        end % yaw

        function reset( obj )

            obj.Transform.Matrix = eye( 4 );

        end % reset

        function setAttitude( obj, roll, pitch, yaw, exaggeration )

            arguments ( Input )
                obj(1, 1) AircraftChart 
                roll(1, 1) double {mustBeReal, mustBeFinite}
                pitch(1, 1) double {mustBeReal, mustBeFinite}
                yaw(1, 1) double {mustBeReal, mustBeFinite} = 0
                exaggeration(1, 1) double ...
                    {mustBeNonnegative, mustBeFinite} = 1
            end % arguments ( Input )

            roll = deg2rad( roll ) * exaggeration;
            pitch = deg2rad( pitch ) * exaggeration;
            yaw = deg2rad( yaw ) * exaggeration;
            rollMatrix = makehgtform( "yrotate", roll );
            pitchMatrix = makehgtform( "xrotate", pitch );
            yawMatrix = makehgtform( "zrotate", yaw );
            obj.Transform.Matrix = rollMatrix * pitchMatrix * yawMatrix;

        end % setAttitude

        function varargout = title( obj, varargin )
            %TITLE Add the specified title to the aircraft chart.

            [varargout{1:nargout}] = title( obj.Axes, varargin{:} );

        end % title

        function box( obj, varargin )
            %BOX Control chart axes box.

            box( obj.Axes, varargin{:} )

        end % box

        function varargout = view( obj, varargin )
            %VIEW Camera line of sight.

            [varargout{1:nargout}] = view( obj.Axes, varargin{:} );

        end % view

        function varargout = axis( obj, varargin )
            %AXIS Set axis limits and aspect ratios.

            [varargout{1:nargout}] = axis( obj.Axes, varargin{:} );

        end % axis

    end % methods

    methods ( Access = protected )

        function setup( obj )

            % Obtain the chart's tiled layout.
            tl = obj.getLayout();

            % Define the color scheme used for the aircraft.
            blue = [0, 0.447, 0.741];
            gray = 0.95 * ones(1, 3);
            onesMatrix = ones(250, 3);
            paintJob = [gray .* onesMatrix; blue .* onesMatrix];

            % Create and customize the axes.
            x = [-2000, 2000];
            y = [-2500, 4500];
            z = [-2500, 2500];
            obj.Axes = axes( "Parent", tl, ...
                "Colormap", paintJob, ...
                "View", [225, 25], ...
                "DataAspectRatio", [1, 1, 1], ...
                "XLim", x, ...
                "YLim", y, ...
                "ZLim", z, ...
                "XTickLabel", [], ...
                "YTickLabel", [], ...
                "ZTickLabel", [], ...
                "NextPlot", "add");

            % Add the transform and patch.
            obj.Transform = hgtransform( "Parent", obj.Axes );
            obj.Patch = trisurf( obj.Triangulation, ...
                "Parent", obj.Transform, ...
                "FaceAlpha", 0.9, ...
                "FaceColor", "interp", ...
                "EdgeAlpha", 0, ...
                "FaceLighting", "gouraud" );

            % Add a title, lighting from above, and give the patch a shiny
            % appearance by adjusting lighting properties.
            title( obj.Axes, "Aircraft Attitude" )
            light( obj.Axes, "Position", [0, 0, 1] )
            material( obj.Axes, "shiny" )

        end % setup

        function update( obj )

            faces = obj.Triangulation(:, :);
            pts = obj.Triangulation.Points;
            set( obj.Patch, "Faces", faces, ...
                "Vertices", pts, ...
                "FaceVertexCData", pts(:, 3) )

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function rotate( obj, type, theta )

            arguments
                % Chart object.
                obj(1, 1) AircraftChart
                % Possible angles of rotation: roll, pitch and yaw.
                type(1, 1) string ...
                    {mustBeMember( type, ["roll", "pitch", "yaw"] )}
                % Angular value to rotate by.
                theta(1, 1) double {mustBeReal, mustBeFinite} = 0
            end % arguments

            switch type
                case "roll"
                    rotAxis = "y";
                case "pitch"
                    rotAxis = "x";
                case "yaw"
                    rotAxis = "z";
            end % switch/case

            % Convert the angle to radians and then update the
            % transformation matrix.
            theta = deg2rad( theta );
            obj.Transform.Matrix = obj.Transform.Matrix * ...
                makehgtform( rotAxis + "rotate", theta );

        end % rotate

    end % methods ( Access = private )

end % classdef

function tr = defaultAircraft()
%DEFAULTAIRCRAFT Import an aircraft triangulation.

arguments ( Output )
    tr(:, 3) triangulation
end % arguments ( Output )

% Attempt to read the file locally.
filename = "avion31.stl";
if isfile( filename )
    tr = stlread( filename );
    return
end % if

% Import the triangulation. 
% Reference:
% Airplane by Yorchmur, https://www.printables.com/model/34767-airplane, 
% licensed under the Creative Commons Attribution 4.0 International 
% License.
url = "https://files.printables.com/media/prints/34767/stls/" + ...
    "343468_b085a064-c28f-4861-b1a0-6a559929a7e2/avion31.stl";
opts = weboptions( "ContentReader", @stlread );
tr = webread( url, opts );

end % defaultAircraft