% Ralf Mouthaan
% University of Adelaide
% August 2024
% 
% Class for controlling Aviivacam from Matlab. Relies on
% AviivaCam.dll and AviivaCam.h, which were written to replace Mingzhou's
% code which no longer works. Written for Freja Hoier.

classdef AviivaCam

    properties

        bolStartup = false;
        bolStreaming = false;
    end

    methods

        function obj = AviivaCam()

            % Load DLL
            if libisloaded('AviivaCamDll')
                unloadlibrary('AviivaCamDll');
            end
            loadlibrary('AviivaCamDll', 'AviivaCamDll.h');

        end
        function delete(~)

            if libisloaded('AviivaCamDll') == false
                return;
            end

            unloadlibrary('AviivaCam');

        end

        function me = Startup(me)

            fprintf('Aviiva Cam: Starting up...\n')

            % Call startup
            Err = calllib('AviivaCamDll', 'Startup');
            switch Err
                case -1
                    unloadlibrary('AviivaCam');
                    error('Could find camera. Is camera connected, and is MAC address correct?');
                case -2
                    unloadlibrary('AviivaCam');
                    error('Unable to connect to camera');
                case -3
                    unloadlibrary('AviivaCam');
                    error('Cannot stream from camera');
                case -4
                    unloadlibrary('AviivaCam');
                    error('Camera does not support GEV');
            end

            me.bolStartup = true;

        end
        function me = Shutdown(me)
            
            fprintf('Aviiva Cam: Shutting Down...\n')
            
            if me.bolStartup == false
                return;
            end

            calllib('AviivaCamDll', 'Shutdown');
            me.bolStartup = false;

        end
        
        function me = StartStreaming(me)

            fprintf('Aviiva Cam: Starting streaming...\n')

            % Check we're not already streaming
            if me.bolStreaming == true
                return;
            end

            % Check camera is on.
            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Start camera before you start streaming');
            end

            calllib('AviivaCamDll', 'StartStreaming');

            me.bolStreaming = true;

        end
        function me = StopStreaming(me)

            fprintf('Aviiva Cam: Stopping Streaming\n')

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started');
            end
            if me.bolStreaming == false
                unloadlibrary('AviivaCam');
                error('Camera is not streaming');
            end

            calllib('AviivaCamDll', 'StopStreaming');

            me.bolStreaming = false;

        end
        
        function Image = GetImage(me)

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started');
            end
            if me.bolStreaming == false
                unloadlibrary('AviivaCam');
                error('Camera is not streaming');
            end

            Width = me.GetWidth();
            Height = me.GetHeight();
            Image = zeros(Width, Height);
            [Err, Image] = calllib('AviivaCamDll', 'GetImage', Image);

            switch Err 
                case -1
                    unloadlibrary('AviivaCam');
                    error('Failed to acquire image buffer');
                case -2
                    unloadlibrary('AviivaCam');
                    error('Failed to acquire image');
                case -3
                    unloadlibrary('AviivaCam');
                    error('Failed to acquire image');
            end

            Image = Image.'; % We seem to need to flip it.

        end
        
        function Width = GetWidth(me)

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started')
            end

            Width = 0;
            [Err, Width] = calllib('AviivaCamDll', 'GetWidth', Width);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not determine image width');
            end
            if Width == 0
                unloadlibrary('AviivaCam');
                error('Could not determine image width')
            end

        end
        function Height = GetHeight(me)

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started')
            end

            Height = 0;
            [Err, Height] = calllib('AviivaCamDll', 'GetHeight', Height);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not determine image height');
            end
            if Height == 0
                unloadlibrary('AviivaCam');
                error('Could not determine image height')
            end

        end
        function Gain = GetGain(me)

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started');
            end

            Gain = 0.0;
            [Err, Gain] = calllib('AviivaCamDll', 'GetGain', Gain);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not determine camera gain');
            end

        end
        function SetGain(me, Gain)

            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started');
            end
            if me.bolStreaming == true
                unloadlibrary('AviivaCam');
                error('Cannot change gain while camera is streaming');
            end

            Err = calllib('AviivaCamDll', 'SetGain', Gain);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not set gain');
            end

        end
        function Exposure = GetExposure(me)
    
            if me.bolStartup == false
                unloadlibrary('AviivaCam');
                error('Camera has not been started')
            end

            Exposure = 0.0;
            [Err, Exposure] = calllib('AviivaCamDll', 'GetExposure', Exposure);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not determine camera exposure');
            end

        end
        function me = SetExposure(me, Exposure)

           if me.bolStartup == false
               unloadlibrary('AviivaCam');
                error('Camera has not been started');
            end
            if me.bolStreaming == true
                unloadlibrary('AviivaCam');
                error('Cannot change exposure while camera is streaming');
            end

            Err = calllib('AviivaCamDll', 'SetExposure', Exposure);

            if Err ~= 0
                unloadlibrary('AviivaCam');
                error('Could not set exposure');
            end

        end

    end
end