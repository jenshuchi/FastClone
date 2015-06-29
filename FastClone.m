function FastClone
%
%
%
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
   
    % Create data.
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
    global polygonInsideValues;
    polygonInsideValues = [];
    global lambdaList;
    lambdaList = [];
    global counter;
    counter = 0;
    global hOutputImage;
    hOutputImage = [];
   
    % Initialize the GUI.
    % Change units to normalized so components resize 
    % automatically.
    set( [ window, hAxes1, hAxes2, hClear, hCopy, hPaste, htext, hpopup ], 'Units', 'normalized' );
    % Assign the GUI a name to appear in the window title.
    set( window, 'Name', 'Simple GUI' )
    % Move the GUI to the center of the screen.
    movegui( window, 'center' )
    % Make the GUI visible.
    set( window, 'Visible', 'on' );

    %  Callbacks for FastClone. These callbacks automatically
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
  
    % Push button callbacks.

    function clear_button_Callback( source, eventdata ) 
    % Clear impoly handles.
        delete( hCreatePolygon );
        delete( hPastePolygon );
    end
 
    function copy_button_Callback( source, eventdata ) % TODO: turn of draggable
    % Copy the intensities of the points inside the polygon which user specifies in the source image.
        setVerticesDraggable( hCreatePolygon, 0 );
        polygonMask = createMask( hCreatePolygon );
        size(polygonMask)
        [ x, y ] = find( polygonMask );
        polygonInsidePoints = [ x, y ];
        for ii=1:size(polygonInsidePoints,1)
           pix = imageSource( polygonInsidePoints(ii,1), polygonInsidePoints(ii,2), : );
           polygonInsideValues(ii) = getIntensity( pix );
        end
        return_copy=1
    end
 
    function paste_button_Callback( source, eventdata ) 
        % Create a new impoly handle in the output image, and compute the MVC lambda.
        boundaryPoints = polygonPoints;
        %boundaryInsidePoints = polygonInsidePoints;
        axes( hAxes2 );
        hold on;
        hPastePolygon = impoly( gca, boundaryPoints );
        setVerticesDraggable( hPastePolygon, 0 );
        addNewPositionCallback( hPastePolygon, @move_polygon_callback );
        fcn2 = makeConstrainToRectFcn( 'impoly', get(gca,'XLim')+[1,-1], get(gca,'YLim')+[1,-1] );
        setPositionConstraintFcn( hPastePolygon, fcn2 );
        lambdaList = MVC( polygonInsidePoints, polygonPoints );
        %size(polygonInsidePoints)
        %size(boundaryInsidePoints)
    end 
   
    function select_button_1_Callback( source, eventdata )
        % Pop a window, let the user select the source image. Create an impoly
        % handle, let the user create a polygon.
        [ FileName, PathName ] = uigetfile( {'*.png';'*.jpg'}, 'Select the MATLAB code file' );
        FullPath = strcat( PathName, FileName );
        imageSource = imread( FullPath );
        axes( hAxes1 );
        image( imageSource );
        hold on;
        hCreatePolygon = impoly;
        polygonPoints = getPosition( hCreatePolygon );
        addNewPositionCallback( hCreatePolygon, @add_new_position_callback );
        fcn = makeConstrainToRectFcn( 'impoly', get(gca,'XLim')+[1,-1], get(gca,'YLim')+[1,-1] );
        setPositionConstraintFcn( hCreatePolygon, fcn );
        %set(IMG1,'ButtonDownFcn',{@image_click_Callback});
    end
    
    function select_button_2_Callback( source, eventdata )
    % Pop a window, let the user select the target image.
        [ FileName, PathName ] = uigetfile( {'*.png';'*.jpg'}, 'Select the MATLAB code file' );
        FullPath = strcat( PathName, FileName );
        imageTarget = imread( FullPath );
        imageOutput = imageTarget;
        axes( hAxes2 );
        hOutputImage = image( imageOutput );
        hold on;
    end
  
    function add_new_position_callback( p )
        polygonPoints = p;
    end
    
    function move_polygon_callback( p )
    % When the user moves the polygon in the target image, compute the
    % output image rgb, and then refresh the output image.
        counter = counter + 1;
        fprintf( 'Moving: %d', counter );
        if counter >= 20
            counter = 0;
            boundaryInsidePoints = polygonInsidePoints;
            moveVector = p(1,:) - polygonInsidePoints(1,:);
            imageOutput = imageTarget;
            tmp = ones(size(polygonInsidePoints));
            tmp = [ tmp(:,1)*moveVector(2), tmp(:,2)*moveVector(1) ];
            boundaryInsidePoints = boundaryInsidePoints + tmp;
            %boundaryMask = createMask( hPastePolygon );
            %[ x, y ] = find( boundaryMask );
            %boundaryInsidePoints = [ x, y ];
            
            %size(boundaryInsidePoints)  
            
            polygonValues = zeros(size(polygonPoints,1),1);
            boundaryValues = zeros(size(boundaryPoints,1),1);
            for ii=1:size(polygonPoints,1)
                pix = imageSource( floor(polygonPoints(ii,2)), floor(polygonPoints(ii,1)), : );
                polygonValues(ii) = getIntensity( pix );
                pix = imageTarget( round(boundaryPoints(ii,2)), round(boundaryPoints(ii,1)), : );
                boundaryValues(ii) = getIntensity( pix );
            end
            
            l = size(polygonInsidePoints,1);
            if size(polygonInsidePoints,1) > size(boundaryInsidePoints,1)
                l = size(boundaryInsidePoints,1);
            end
            newIntensities = mvcClone( lambdaList, imageTarget, imageSource, l, polygonInsideValues, polygonValues, boundaryValues );
            size(newIntensities)
            size(polygonInsidePoints)
            size(boundaryInsidePoints)
            for ii=1:l
                x = round(boundaryInsidePoints(ii,2));
                y = round(boundaryInsidePoints(ii,1));
                pix = imageTarget( x, y, : );
                oldIntensity = getIntensity( pix );
                intensityScale = newIntensities(ii) / oldIntensity;
                pix = pix * intensityScale;
                pix = uint8(pix);
                imageOutput( y, x, : ) = pix;
            end
            fprintf( 'Finish moving\n' );
            drawnow update
            %axes( hAxes2 );
            hAxes2.cdata = imageOutput;
            set( hOutputImage, 'CData', imageOutput ) %refresh image
            drawnow
            %refresh( window );
        end
    end
    
    function intensity = getIntensity( pix )
        s = reshape( [0.299;0.587;0.114], 1, 1, 3 );
        intensity = sum( s .* double(pix) );
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