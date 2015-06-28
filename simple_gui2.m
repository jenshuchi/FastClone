function simple_gui2
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
 
   %  Create and then hide the GUI as it is being constructed.
   window = figure( 'Visible', 'off', 'Position', [360,500,940,340] );
 
   %  Construct the components.
   hClear = uicontrol( 'Style', 'pushbutton', 'String', 'Clear', 'Position', [440,300,70,25], 'Callback', {@clear_button_Callback} );
   hCopy = uicontrol( 'Style', 'pushbutton', 'String', 'Copy', 'Position', [440,260,70,25], 'Callback', {@copy_button_Callback});
   hPaste = uicontrol( 'Style', 'pushbutton', 'String', 'Paste', 'Position', [440,220,70,25], 'Callback', {@paste_button_Callback}); 
   hSelectImage1 = uicontrol( 'Style', 'pushbutton', 'String', 'image 1', 'Position', [440,180,70,25], 'Callback', {@select_button_1_Callback} );
   hSelectImage2 = uicontrol( 'Style', 'pushbutton', 'String', 'image 2', 'Position', [440,140,70,25], 'Callback', {@select_button_2_Callback} );
   htext = uicontrol('Style','text','String','Select Data','Position',[440,100,60,15]);
   hpopup = uicontrol('Style','popupmenu','String',{'Peaks','Membrane','Sinc'},'Position',[440,60,100,25],'Callback',{@popup_menu_Callback});
   hAxes1 = axes( 'Units', 'Pixels', 'Position', [20,20,400,300] );
   hAxes2 = axes( 'Units', 'Pixels', 'Position', [520,20,400,300] );
   %align( [ hClear, hCopy, hPaste, htext, hpopup ], 'Center', 'None' );
   
   % Create the data to plot.
   peaks_data = peaks(35);
   membrane_data = membrane;
   [x,y] = meshgrid(-8:.5:8);
   r = sqrt(x.^2+y.^2) + eps;
   sinc_data = sin(r)./r;
   global imageSource;
   global imageTarget;
   global imageOutput;
   global hCreatePolygon;
   global polygonPoints;
   polygonPoints = [];
   global boundaryPoints;
   boundaryPoints = [];
   global hPastePolygon;
   hPastePolygon = [];
   global polygonMask;
   polygonMask = [];
   global boundaryMask;
   boundaryMask = [];
   global polygonInsidePoints;
   polygonInsidePoints = [];
   global boundaryInsidePoints;
   boundaryInsidePoints = [];
   global polygonInsideValue;
   polygonInsideValue = [];
   global lambdaList;
   lambdaList = [];
   
   % Initialize the GUI.
   % Change units to normalized so components resize 
   % automatically.
   set( [ window, hAxes1, hAxes2, hClear, hCopy, hPaste, htext, hpopup ], 'Units', 'normalized' );
   %Create a plot in the axes.
   current_data = peaks_data;
   surf(current_data);
   % Assign the GUI a name to appear in the window title.
   set( window, 'Name', 'Simple GUI' )
   % Move the GUI to the center of the screen.
   movegui( window, 'center' )
   % Make the GUI visible.
   set( window, 'Visible', 'on' );
 
   %  Callbacks for simple_gui. These callbacks automatically
   %  have access to component handles and initialized data 
   %  because they are nested at a lower level.
 
   %  Pop-up menu callback. Read the pop-up menu Value property
   %  to determine which item is currently displayed and make it
   %  the current data.
      function popup_menu_Callback( source, eventdata ) 
         % Determine the selected data set.
         str = get(source, 'String');
         val = get(source,'Value');
         % Set current data to the selected data set.
         switch str{val};
         case 'Peaks' % User selects Peaks.
            current_data = peaks_data;
         case 'Membrane' % User selects Membrane.
            current_data = membrane_data;
         case 'Sinc' % User selects Sinc.
            current_data = sinc_data;
         end
      end
  
   % Push button callbacks. Each callback plots current_data in
   % the specified plot type.
 
   function clear_button_Callback( source, eventdata ) 
   % Display surf plot of the currently selected data.
      delete( hCreatePolygon );
      delete( hPastePolygon );
   end
 
   function copy_button_Callback( source, eventdata ) 
   % Display mesh plot of the currently selected data.
       polygonMask = createMask( hCreatePolygon );
       [ x, y ] = find( polygonMask );
       polygonInsidePoints = [ x, y ];
       for ii=1:size(polygonInsidePoints,1)
           polygonInsideValue(ii) = imageSource( polygonInsidePoints(ii,1), polygonInsidePoints(ii,2) );
       end
       return_copy=1
   end
 
   function paste_button_Callback( source, eventdata ) 
   % Display contour plot of the currently selected data.
       boundaryPoints = polygonPoints;
       axes( hAxes2 );
       hold on;
       hPastePolygon = impoly( gca, polygonPoints );
       setVerticesDraggable( hPastePolygon, 0 );
       addNewPositionCallback( hPastePolygon, @move_polygon_callback );
       fcn2 = makeConstrainToRectFcn( 'impoly', get(gca,'XLim'), get(gca,'YLim') );
       setPositionConstraintFcn( hPastePolygon, fcn2 );
       lambdaList = MVC( polygonPoints, polygonInsidePoints );
   end 
   
   % File selection
    function select_button_1_Callback( source, eventdata )
        [FileName,PathName] = uigetfile( {'*.png';'*.jpg'}, 'Select the MATLAB code file' );
        FullPath = strcat( PathName, FileName );
        imageSource = imread( FullPath );
        axes( hAxes1 );
        image( imageSource );
        hold on;
        hCreatePolygon = impoly;
        polygonPoints = getPosition( hCreatePolygon );
        addNewPositionCallback( hCreatePolygon, @add_new_position_callback );
        fcn = makeConstrainToRectFcn( 'impoly', get(gca,'XLim'), get(gca,'YLim') );
        setPositionConstraintFcn( hCreatePolygon, fcn );
        %set(IMG1,'ButtonDownFcn',{@image_click_Callback});
    end
    
    function select_button_2_Callback( source, eventdata )
        [ FileName, PathName ] = uigetfile( {'*.png';'*.jpg'}, 'Select the MATLAB code file' );
        FullPath = strcat( PathName, FileName );
        imageTarget = imread( FullPath );
        imageOutput = imageTarget;
        axes( hAxes2 );
        image( imageOutput );
        hold on;
    end
  
    function add_new_position_callback( p )
        polygonPoints = p;
    end
    
    function move_polygon_callback( p )
        boundaryPoints = p;
        imageOutput = imageTarget;
        boundaryMask = createMask( hPastePolygon );
        [ x, y ] = find( boundaryMask );
        boundaryInsidePoints = [ x, y ];
        newIntensity = mvcClone( lambdaList, imageTarget, imageSource, polygonInsidePoints, boundaryInsidePoints, polygonPoints, boundaryPoints );
        size(newIntensity)
    end
    
        % Draw on image
    function image_click_Callback( source, eventdata )
        %{
        %% old style
        ah = get( source, 'Parent' );
        coord = get( ah, 'CurrentPoint' );
        p = coord(1,1:2);
        plot( p(1), p(2), 'k:diamond' );
        last = size(dPs,1);
        if last >=1
            plot( [dPs(last,1), p(1)], [dPs(last,2), p(2)] );
        end
        dPs = [ dPs; p ]
        %}
    end
end 