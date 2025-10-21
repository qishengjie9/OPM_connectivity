# The impact of channel density, inverse solutions, connectivity metrics and calibration errors on OPM-MEG connectivity analysis
This repository contains codes to run the analyses presented in: The impact of channel density, inverse solutions, connectivity metrics and calibration errors on OPM-MEG connectivity analysis.
Optically pumped magnetometers (OPMs) magnetoencephalography (MEG) systems have been rapidly developing in
the fields of brain function, health and disease. Functional connectivity analysis related to resting-state is an important
research area in the last two decades. There have been studies attempting to use OPM-based MEG (OPM-MEG)
for brain network estimation research. Nevertheless, the different choices in the source connectivity analysis pipeline
might lead to outcome variability problem of resulting functional network. Several methods and related parameters need
careful selection and tuning in each step of the analysis. In the present study, we assessed the impact of such analytical
variability on OPM-MEG connectivity analysis through simulations. We generated synthetic MEG data corresponding
to two default mode networks (DMN) with six or ten DMN regions using the Gaussian Graphical Spectral (GGS)
model. Six inter-sensor spacings (15/20/25/30/35/40 mm) were constructed. Six inverse algorithms and six functional
connectivity measures were chosen to assess their impact on the accuracy of network reconstruction. Three potential
sources of error including the errors in sensor gain, crosstalk and angular errors in the sensitive axis of OPM were also
assessed regarding their impact on the results.

We believe that this work could be useful for the field of electrophysiology connectomics, by shedding light on the challenge of analytical variability and its consequences on the reproducibility of neuroimaging studies.

## Simulations
The simulations of cortical networks were created based on an underlying Gaussian Graphical Spectral (GGS) model. 
This model needs a custom Hermitian complex-valued precision matrix which generates the intended activities of specified functional connectivity. 
The GGS model is valid for brain-like broadband oscillations covering the frequency bands of 0.5 to 140Hz. 
The off-diagonal values in the precision matrix (or inverse of its cross-spectrum) can define the functional connectivity parameters. 
A function of the Hermitian tensor at all frequency can determine all statistical properties of functional connectivity based on previous studies. 
Here the MEG data corresponding to the resting-state networks (RSNs), specifically the default mode network (DMN), was simulated using the GGS model. 
Two simulated cortical networks included six or ten regions representing simple and complex networks respectively based on the Desikan-Killiany atlas in terms of region parcellation. 
The simple DMN network consisted of the left and right posterior cingulate cortex (PCC), medial orbitofrontal (MOF) gyrus, and inferior parietal lobe (IPL),
while the complex DMN network added the left and right precuneus (PCUN), isthmus cingulate (ICC) into the simple DMN network, considering the common occurrence of these regions in earlier RSNs researches. 
The DMN is characterised by a less distributed architecture, with small to moderate distances between these selected regions. 
The synthetic cortical activity was simulated by the superposition of Alpha and Xi processes. 
Wherein alpha process has a spectral peak with its maximum at the traditional alpha band, while Xi process appears as a background activity with spectral maximum at very low frequency. 
## Tested parameters:
  1) Channel densities: 15/20/25/30/35/40 mm
  2) Inverse solutions:
      - minimum norm estimate (MNE)
      - weighted minimum norm estimate (wMNE)
      - exact low resolution brain electromagnetic tomography (eLORETA)
      - standardized low resolution electromagnetic tomography (sLORETA)
      - linearly constrained minimum variance (LCMV) beamforming 
      - unit-noise-gain minimum variance (UNGMV) beamformer
  3) Functional connectivity measures:
      - phase-locking value (PLV)
      - weighted phase lag index (wPLI)
      - debiased weighted phase lag index(wPLI*)
      - phase slope index (PSI)
      - amplitude envelope correlation (AEC) without source leakage correction
      - amplitude envelope correlation (AEC) with source leakage correction
  

## Running the code:
- To obtain the connectivity matrices of all subjects and epochs (under reference case, case 1 and case 2), run "run_all_epochs()".
- To obtain the connectivity matrices of all subjects and epochs (under calibration error condition), run "run_all_epochs_error()" and "run_all_epochs_angularerror()".
- To get the results quantification (Pearson correlation, closeness accuracy, edge contribution) run "get_results_quantif()".
- To get the statistical analysis, please refer to "results statistical analysis.txt"

* Please check that the path to data is correct prior to running the codes
## Acknowledgments
The authors would like to thank Sahar Allouch at University of Rennes, Tim Tierney at UCL Institute of Neurology and Deirel Paz-Linares at University of Electronic Science and Technology of China for their code sharing in their previous publications.

## References
- [1] D. Paz-Linares, E. Gonzalez-Moreira, A. Areces-Gonzalez, Y. Wang, M. Li, E. Martinez-Montes, J. Bosch-Bayard, M. L.Bringas-Vega, M. Valdes-Sosa, P. A. Valdes-Sosa, Identifying oscillatory brain networks with hidden gaussian graphical spectral models of meeg, Scientific Reports 13 (1) (2023) 11466.
- [2] Desikan, Rahul S., Florent Ségonne, Bruce Fischl, Brian T. Quinn, Bradford C. Dickerson, Deborah Blacker, Randy L. Buckner, et al. 2006. “An Automated Labeling         System for Subdividing the Human Cerebral Cortex on MRI Scans into Gyral Based Regions of Interest.” NeuroImage 31: 968–80.
- [3] S. Allouch, A. Kabbara, J. Duprez, M. Khalil, J. Modolo,  M. Hassan, Effect of channel density, inverse solutions and connectivity measures on eeg resting-state networks reconstruction: A simulation study, NeuroImage 271 (2023) 120006.
- [4] T. M. Tierney, S. Mellor, G. C. O’Neill, N. Holmes, E. Boto, G. Roberts, R. M. Hill, J. Leggett, R. Bowtell, M. J. Brookes, et al., Pragmatic spatial sampling for wearable meg arrays, Scientific reports 10 (1) (2020) 21609
