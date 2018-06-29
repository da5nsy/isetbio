function [oiObjects, seObjects] = downloadFromCloud(gcp,varargin)
%DOWNLOADFROMCLOUD Download rendered data from the cloud. 
%
% An variation of the function "downloadPBRT" from isetcloud but adapated to
% work specifically for sceneEye. (We need to do some extra processing
% specific to the sceneEye class.)
%
% Inputs:
%    gcp - the intalized gCloud object from isetcloud
%    varargin  - An optional length of key/value pairs describing the scene
%
% Outputs:
%    oiObjects - All the optical images rendered.
%    seObjects - Corresponding scene eye objects. 
%
% History:
%    4/26/18  TL   Created
%%
p = inputParser;
p.addRequired('gcp',@(x)(isa(x,'gCloud')));

oiObjects = [];
seObjects = [];

%% Download

oiObjects = gcp.downloadPBRT(gcp.miscDescriptor(1).recipe);

for ii=1:length(oiObjects)
    
    % Get corresponding sceneEye object
    % Check, is this correct?
    seObjects{ii} = gcp.miscDescriptor(ii).copy;
    
    % Set the parameters correctly for the optical image
    if(seObjects{ii}.debugMode == 1)
        % seObject is a scene. Don't try to set it as an optical image,
        % just return it. 
        oiObjects{ii} = oiObjects{ii};
    else
        oiObjects{ii} = seObjects{ii}.setOI(oiObjects{ii});
    end
    
end


end

