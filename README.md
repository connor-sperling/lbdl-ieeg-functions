# LBDL iEEG Functions

## Pre-processing

### iEEGprocessor.m

Entry point for all iEEG data cleaning and pre-processing

## Stimulus/Response-locked Analysis

### iEEGanalysis.m

Entry point for performing stimulus and/or response-locked analysis of pre-processed iEEG data

## Connectivity Map Generation

### generate_connectivity_maps.m

### binarize_connectivity_maps.m

The weights of the adjacency matrices created by gl_ar.m do not contain relevant information in the context of connectivity within the brain during stimulus events. We are only interested in whether or not a connection between electrode regions was calculated. \
This function opens up the connectivity map files, containing the connectivity map adjaceny matrices for every significant event, and assigns a 1 or 0 in-place of the connection weights. Matrix entries are assigned 1 (connection) if the connection weight exceeds a defined (possibly calculated, if specified within the script) threshhold. The 'binarized' adjacency matrices, defining connections between significant electrodes for every event, are saved in a 3D array (num. electrode x num. electrode x num. events).

### average_adjacency_matrices.m
