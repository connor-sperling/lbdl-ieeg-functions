# LBDL iEEG Functions

## Pre-processing

### iEEGprocessor.m

Entry point for all iEEG data cleaning and pre-processing

## Stimulus/Response-locked Analysis

### iEEGanalysis.m

Entry point for performing stimulus and/or response-locked analysis of pre-processed iEEG data

## Connectivity Map Generation

*connectivity_map_driver.m*: entry point for connectivity map generation and analysis

1. Set global variables
2. Configure i/o information
3. Bipolar reference the localized data (*bipolar_reference_loc_data.m*)
4. Make excel file that organizes/associates electode data with brain-region names (*write_significant_localization_table.m*)
5. Re-order data to match the ordered list of brain regions
   - Orders the data to correspond to the order in the      "significant localization table" that was just made in the previous function
6. remove "significant data" (determination from *IEEGanalysis.m*) from electrodes localized to the white matter (*remove_white_matter_channels.m*).
7. Generate connectivity maps. One connectivity map generated for every task stimulus event. Generated with data from electrodes exhibiting activity during the stimulus event. (*generate_connectivity_maps.m*)
8. Create connectivity maps from down-time between two events (surrogate connectivity maps). The nodes of the graph correspond to each tasks' significant electrode data. (*generate_surrogate_connectivity_maps_break.m*)
9. Create binary connectivity maps from every connectivity map (stimulus-related and break data). (*binarize_adjacency_matricies.m*)
10. Average binarized connectivity maps (adjacency matrices). Average is performed element-wise from sets of stimulus events.

### generate_connectivity_maps.m

### binarize_connectivity_maps.m

The weights of the adjacency matrices created by gl_ar.m do not contain relevant information in the context of connectivity within the brain during stimulus events. We are only interested in whether or not a connection between electrode regions was calculated. \
This function opens up the connectivity map files, containing the connectivity map adjaceny matrices for every significant event, and assigns a 1 or 0 in-place of the connection weights. Matrix entries are assigned 1 (connection) if the connection weight exceeds a defined (possibly calculated, if specified within the script) threshhold. The 'binarized' adjacency matrices, defining connections between significant electrodes for every event, are saved in a 3D array (num. electrode x num. electrode x num. events).

### average_adjacency_matrices.m
