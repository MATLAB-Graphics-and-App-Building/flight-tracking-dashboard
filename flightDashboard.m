function varargout = flightDashboard( f )
%FLIGHTDASHBOARD Application launcher.

arguments ( Input )
    f(1, 1) matlab.ui.Figure = uifigure( ...
        "Name", "Flight Dashboard", ...
        "AutoResizeChildren", "off" )
end % arguments ( Input )

% Check the number of output arguments.
nargoutchk( 0, 1 )

% Check for the required dependencies.
v = ver( "layout" );
if isempty( v )
    uialert( f, "This application requires " + ...
        "<a href=""https://www.mathworks.com/" + ...
        "matlabcentral/fileexchange/" + ...
        "47982-gui-layout-toolbox"">" + ...
        "GUI Layout Toolbox</a>. Please install this" + ...
        " toolbox and restart the application.", ...
        "Flight Dashboard: Missing Dependency", ...
        "Interpreter", "html", ...
        "CloseFcn", @( ~, ~ ) delete( f ) )
    return
end % if

% Launch the application.
FDL = FlightDashboardLauncher( f );

% Return the figure handle, if requested.
if nargout == 1
    varargout{1} = FDL.Figure;
end % if

end % flightDashboard