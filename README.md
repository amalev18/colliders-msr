# Replication Package
This repository contains the replication package of the study conducted in the Master Thesis Causal Models Applied to a Study within Mining Software Repository Mining. First a short description of the aim of the thesis will be presented. Following that, a description of the files present in the repo is explained along with what they contain. Lastly, required steps for replication are stated.

## Short Description of the Thesis
What was investiagted during the study was the practical implications of accidently conditioning on collider variables in research conducted in the domain of mining software repositories. A paper was chosen from the Mining Software Repository (MSR) conference, based on selection criteria, as subject in the thesis and on which the analyses were made. The paper chosen as subject was On the Co-Occurrence of Refactoring of Test and Source Code by Nicholas Alexandre Nagy and Rabe Abdalkareem. In short, the authors are interested in predicting when a test code refactoring (TR) would co-occur with a source code refactoring (SR). The study was conducted by performing computer simulations.


## Structure of Repository
The first simulation conducted was an independent simulation of a possible scenario in software engineering was performed. This, in order to justify making similar investigations for a real research scenario. The code for this simulation can be found in the folder `theoretical_se_scenario`. 

Following that inital simulation, simulations were further conducted based upon a paper identified from the MSR conference. In addition to the simulations, an analysis using the empirical data from the research paper was also carried out. All material for this can be found in the `msr_paper_analysis` folder. It contains one folder for the simulations, and one for the analysis with the empirical data. In more detail, each folder contains the following:

### `msr_paper_analysis/simulations`
* `direct_effect.R`: Simulation of the direct causal effect of SR on TR.
* `total_effect.R`: Simulation of the total causal effect of SR on TR.
* `investigation_real_data.ipynb`: The simulated data was generated with the purpose of capturing characteristics of the real empirical data. This file contains the investigations made on that data.

### `msr_paper_analysis/analysis_w_real_data`
* `analysis_w_real_data.R`: This file contains the analysis of including collider variables using the empirical data. 
* `/data`: A folder with all necessary data. `commit_all_features.csv` is the original data used in the identified research paper for conducting their predictions. The authors of the research paper had filtered away some raw data, data which was required for this study. The remaining files in this folder relates to these changes made to this file.
  * `feature_extraction_modified.ipynb`:** A modified version of the original feature extraction file found in the authors replication package. The modification made is clearly stated in the file, and was inserted due to the need for obtaining the test only refactoring commits.
  * `commit_level_features_w_test.csv`: The csv file including test code refactoring only commits. 
  * `manipulation_of_test_column.ipynb`: After obtaning the raw data which had been filtered out by the authors, it was required to be formatted to fit the models designed in this study. This file contains these formattings made. It was in this study not achieved to obtain the raw data for all features. The four features missing this data is also investigated here.
  * `commit_level_features_w_test_modified.csv`: The csv obtained after the transformation of column layout.
  * `commit_level_features_w_test_modified_small.csv`: Subset of the above file, only containing the features utilized in the models used when conducting the analysis with empirical data.


## Replication
For all simulations, they can be replicated by simply running wanted file. They are all independent of each other and do not required other files to be run in order to function. 

To replicate the analysis with the empirical data, the R file `analysis_w_real_data.R` can also be run. However, to replicate the data generation and transformation of the empirical data, there are some steps to follow:
1.  Ensure to download the file `rMinerRefactorings.csv` from the orginial paper and place it in the **same folder** as the `feature_extraction_modified.ipynb` file. Due to the size of it, the file could not be provided in this repository. Instead, it can be found in the replication package of the authors of the paper: https://zenodo.org/records/5979790. 
2.  Run the  `feature_extraction_modified.ipynb` file.
3.  Run the `manipulation_of_test_column.ipynb` file.
