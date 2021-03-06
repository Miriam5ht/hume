function h0 = spectrogramRpt_SingleCh(EEG,ch, stageStats)
% spectrogramRpt_SingleChed(EEG,ch, stageStats)
%
%   Generic Spectrogram Creation Tool (requires signal processing toolbox
%   and EEGLAB)
%
%   Inputs (required)
%
%       EEG - EEGLAB EEG Struct
%
%       ch - string indicating Channel label to analyze (should match those
%       in EEG (e.g., 'C3' or 'C3-A2', depending on data used). The
%       function will currently fail if label is incorrect.
%
%    Inputs (optional)
%
%        stageStats - struct variable 'stageStats' as output of
%        Hume sleep statistics. If included, the function will plot the
%        hypnogram, and overlay NREM cycle averages of Delta/Sigma in Plots
%        3 and 4.
%
%%   Copyright (c) 2019 Jared M. Saletin, PhD
%
%   This file is part of H�m�.
%
%   H�m� is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%
%   H�m� is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%
%   You should have received a copy of the GNU General Public License along
%   with H�m�.  If not, see <http://www.gnu.org/licenses/>.
%
%   H�m� is intended for research purposes only. Any commercial or medical
%   use of this software is prohibited. The authors accept no
%   responsibility for its use in this manner.
%%
EEG = pop_select(EEG,'channel',find(strcmp({EEG.chanlocs.labels},ch)));

if ~isempty(stageStats)
    % Removes unscored data
    stageData = stageStats.stageData; 
    
    % Window definition
    win = stageStats.stageData.win;% stageData.win
    
    % The first scored epoch
    firstEp = min(find(stageData.stages ~= 7));
    
    % The last epoch
    lastEp = max(find(stageData.stages ~= 7));
    %EEG=pop_loadset(eeg);
    
    % The sampling rate (remember we re-set this in line 15)
    srate = EEG.srate; 
    
    % Trim the EEG between first and last scored epochs
    if firstEp ~= 0
        
        EEG = pop_select(EEG,'point',[(1+(firstEp-1)*srate*win) ((lastEp)*srate*win)]);
    elseif firstEp == 0
        
        EEG = pop_select(EEG,'point',[1 ((lastEp)*srate*win)]);
    end
end

%% PWELCH

data = EEG.data;
data = buffer(data,30*EEG.srate,0)';
nfft=5*EEG.srate;
spect = nan(size(data,1), nfft/2 + 1);
for i = 1:size(data,1)
    [pxx] = pwelch(data(i,:), 5*EEG.srate, [], 5*EEG.srate, EEG.srate);
    spect(i,:) = pxx;
end
spect=spect';
Flims = [.05 20];
f = (0:1/(nfft/EEG.srate):EEG.srate/2);

scaleFactor = EEG.pnts / size(data,1);

h0=figure;
h0.Position=[1900 1000 840 1020];
h0.Name=['Spectrogram for Channel: ''',ch,''''];

if ~isempty(stageStats)
    k = 4;
    j=1;
    subplot(k, 1, j);
    
    stages = stageStats.stageData.stages(firstEp:lastEp);
    rasterStages = zeros(7,length(stages));
    for i = 1:length(stages)
        rasterStages(stages(i)+1,i)=1;
    end
    rasterStages=logical(rasterStages);
    plotSpikeRaster(rasterStages,'PlotType','vertline','TimePerBin',stageStats.stageData.win,'spikeDuration',stageStats.stageData.win);
    xlim([0, length(stages)/(60/stageStats.stageData.win)/60]);
    ylim([.5 7.5]);
    xlabel({'Time (hours)'});
    yticks([1:1:7]);
    set(gca,'YTickLabel',{'Wake' 'Stage 1' 'Stage 2' 'Stage 3' 'Stage 4' 'REM' 'MT'});
    
else
    k=3;
    j=0;
end

subplot(k,1,j+1);
h=imagesc([0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60, ...
    f(min(find(f>=Flims(1))):max(find(f<=Flims(2)))),...
    10*log10(spect(min(find(f>=Flims(1))):max(find(f<=Flims(2))),:)));
set(gca,'YDir','normal');
colormap(jet);
ylabel({'Frequency (Hz)'});
caxis([-20 20])
xlabel({'Time (hours)'});
%c=colorbar; c.Location = 'Southoutside';
c.Label.String = 'Power (db)';

delta = trapz(spect(and(f>=.5,f<=4.75),:),1);
if ~isempty(stageStats)
    delta = (delta./mean(delta( intersect(stageStats.milestones(1,1):stageStats.milestones(2,1), find(and(stages>1,stages<5))) )))*100;
    legendText = ('% NREM Avg');
else
    delta = (delta./mean(delta))*100;
    legendText = ('% Whole Night');
end
subplot(k,1,j+2);

h2=area([0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60,delta,'EdgeAlpha',0,'FaceColor',[0 0 0],'FaceAlpha',[.45]);
h2.Parent.XLim = h.Parent.XLim;
ylim([0 prctile(delta,99)]);
xlabel({'Time (hours)'});
ylabel({'Delta [0.6-4.6 Hz]'; legendText});


hold;
if ~isempty(stageStats)
    cycles=stageStats.cycleBoundsJenniSplit;
    for cy=1:size(cycles,1)
        deltaCy(cy)=nanmean(delta(intersect(find(and(stages>1,stages<5)),cycles(cy,1):cycles(cy,2))));
        mid(cy)=median(cycles(cy,1):cycles(cy,2));
    end
    h25=plot(mid./((60/stageStats.stageData.win)*60),deltaCy,'k-s','MarkerSize',10,...
        'MarkerEdgeColor','black',...
        'MarkerFaceColor',[1 1 1],'LineWidth',2);
    legend(h25,'Cycle NREM Avg');
end

sigma = trapz(spect(and(f>=11.9,f<=15.1),:),1);
if ~isempty(stageStats)
    sigma = (sigma./mean(sigma( intersect(stageStats.milestones(1,1):stageStats.milestones(2,1), find(and(stages>1,stages<5))) )))*100;
    legendText = ('% NREM Avg');
else
    sigma = (sigma./mean(sigma))*100;
    legendText = ('% Whole Night');
end

subplot(k,1,j+3);
h3=area([0+(scaleFactor/EEG.srate)/60:(scaleFactor/EEG.srate)/60:size(data,1)*scaleFactor/EEG.srate/60]./60,sigma,'EdgeAlpha',0,'FaceColor',[0 0 0],'FaceAlpha',[.45]);
h3.Parent.XLim = h.Parent.XLim;
ylim([0 prctile(sigma,99)]);
xlabel({'Time (hours)'});
ylabel({'Sigma [12-15 Hz]'; legendText});
hold;
if ~isempty(stageStats)
    cycles=stageStats.cycleBoundsJenniSplit;
    for cy=1:size(cycles,1)
        sigmaCy(cy)=nanmean(sigma(intersect(find(and(stages>1,stages<5)),cycles(cy,1):cycles(cy,2))));
        mid(cy)=median(cycles(cy,1):cycles(cy,2));
    end
    h35=plot(mid./((60/stageStats.stageData.win)*60),sigmaCy,'k-s','MarkerSize',10,...
        'MarkerEdgeColor','black',...
        'MarkerFaceColor',[1 1 1],'LineWidth',2);
    legend(h35,{'Cycle NREM Avg'});
end
h4.Parent.XLim = h.Parent.XLim;


title(h0.Children(end), {EEG.filename;['Sleep Spectrogram Q/A Report: ', ch];'';''}, 'Interpreter', 'none');


end

