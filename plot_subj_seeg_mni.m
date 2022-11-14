clc
close all

MNI152 = niftiread('/Volumes/LBDL Extern/bdl-raw/iEEG_San_Diego/Electrode_localization/mni_icbm152_lin_nifti/icbm_avg_152_t1_tal_lin_mask.nii');

lbdl_subj = 'SD09';
subj = 'SD010';
sloc_dir = sprintf('/Volumes/LBDL Extern/bdl-raw/iEEG_San_Diego/Electrode_localization/processed/%s', subj);

ras_table = readtable(sprintf('%s/%s_contact_RAS.csv', sloc_dir, subj));
r = ras_table.R; a = ras_table.A; s = ras_table.S;
M = max(sum(sqrt([r.^2,a.^2,s.^2]), 2));
nr = r/M; na = a/M; ns = s/M;

RAS = [r a s];
nRAS = [nr na ns];

xfmf = sprintf('%s/FSURF_%s/mri/transforms/talairach.xfm', sloc_dir, subj);
txfm = freesurfer_read_talxfm(xfmf);

[MNIv, TALv] = freesurfer_surf2tal(RAS, txfm);

figure
scatter3(r,a,s,25,'filled')

figure
scatter3(MNIv(:,1),MNIv(:,2),MNIv(:,3),25,'filled')