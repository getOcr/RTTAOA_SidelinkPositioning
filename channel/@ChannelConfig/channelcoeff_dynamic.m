function  [hcoef,info]  = channelcoeff_dynamic(Layout,Chan);
%channelcoeff_dynamic Generate segment-based channel coefficients.
%
% Description:
% Generate channel coefficients according to the segment-based simulations
% in 3GPP TR 38.901 v16.1.0 2019 -- clause 7.6.3 procedure A.
% Spatial consistent mobility modelling (powers, delays, and angles)
% according to TR38.901 clause 7.6.3.2
%
% Developer: Jia. Institution: PML. Date: 2021/10/28

% Large scale parameters
lsp = calc_largescalepara( Chan.center_frequency, Layout.BS_position, ... 
    Layout.UE_position, Chan.Ind_LOS, Chan.Ind_spatconsis, Chan.Ind_O2I, ... 
    Chan.p_indoor, Chan.p_lowloss, Chan.Ind_uplink, Chan.scenario, Chan.nBS, ...
    Chan.nUE,Chan.normrndsm,Chan.unirndsm);
info.lsp = lsp;
% init
hcoef(Chan.nBS, Chan.nUE).H = 0;
% Random varables generation.
r = gen_random_vars_spec( lsp.scenario{1,1}, Layout.UE_position, lsp.Ind_O2I,...
    lsp.Ind_LOS, Chan.Ind_spatconsis, Chan.nBS, Chan.nUE, Chan.nsnap, ...
    Chan.unirndsm , Chan.normrndsm );
for iBS = 1 : Chan.nBS
    for iUE = 1 : Chan.nUE
        % Small scale paras
        ssp = calc_smallscalepara_segment_PA( lsp.para(iBS, iUE), ...
            lsp.lspar(iBS, iUE), lsp.Ind_LOS( iBS, iUE),lsp.Ind_O2I(iUE), ...
            Layout.BS_position(:, iBS), Layout.UE_position(:, iUE), ...
            Layout.UE_speed(iUE), Layout.UEAcceSpeed( iUE ), ...
            Layout.UE_mov_direction(:,iUE), Chan.nsnap, Chan.interval_snap,...
            Layout.c, Chan.Ind_uplink, Chan.normrndsm, Chan.unirndsm, r(iBS, iUE) );
        info.ssp(iBS,iUE) = ssp;
        % Coefficients calc
        [H, timedelay] = gen_link_H_delay_segment(ssp, Layout.BS_array(iBS), ...
            Layout.UE_array(iUE), lsp.Ind_LOS(iBS,iUE), lsp.gainloss_dB(iBS,iUE), ...
            Chan.wavelength, Chan.v_scatter_max, Chan.nsnap, Chan.interval_snap,...
            lsp.epsilon_GRdiv0, Chan.Ind_uplink, Chan.Ind_GR, Chan.Ind_gainloss,...
            Chan.unirndsm);
        hcoef(iBS,iUE).H = H;
        hcoef(iBS,iUE).timedelay = timedelay;
    end
end
end

