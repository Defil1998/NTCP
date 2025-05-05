# NU²D
This repository contains statistics to generate realistic Non-Uniform User Distributions with Non-Terrestrial Cluster Processes (NTCPs) in Non-Terrestrial Networks. The methodology, presented in [1], is based on the HDBSCAN clustering algorithm [2] and Kernel Density Estimation [3] and is applied on tile "R4-C19" (central Europe) of the open database Global Human Settlement Layer (GHSL) by the Joint Research Centre (JRC) of the European Commission, mainly focusing on the GHS-POP R2023A dataset [4].

The repository includes:
- non_uniform_distributions.mat: file containing the statistics described in [1] required to generate a NTCP tailored to the suburban and rural areas in tile R4-C19.
- generateUsers.m: sample function that outputs the vectors containing the latitude and longitude of the generated user locations
- main.m: sample script to illustrate the usage of generateUsers.m

References
[1] B. De Filippo, B. Ahmad, D. G. Riviello, A. Guidotti and A. Vanelli-Coralli, "Non-Uniform User Distribution in Non-Terrestrial Networks with Application to User Scheduling," 2024 IEEE International Mediterranean Conference on Communications and Networking (MeditCom), Madrid, Spain, 2024, pp. 441-446, doi: 10.1109/MeditCom61057.2024.10621409.
[2] R. J. G. B. Campello, D. Moulavi and J. Sander, "Density-based clustering based on hierarchical density estimates," in Advances in Knowledge Discovery and Data Mining, J. Pei, V. S. Tseng, L. Cao, H. Motoda, and G. Xu, Eds. Berlin, Heidelberg: Springer, 2013, vol. 7819, pp. 160–172. doi: 10.1007/978-3-642-37456-2_14.
[3] E. Parzen, “On Estimation of a Probability Density Function and Mode,” The Annals of Mathematical Statistics, vol. 33, no. 3, pp. 1065–76, 1962, JSTOR, http://www.jstor.org/stable/2237880.
[4] M. Schiavina, S. Freire, A. Carioli and K. MacManus, "GHS-POP R2023A - GHS population grid multitemporal (1975-2030)", European Commission Joint Research Centre (JRC), 2023, PID: http://data.europa.eu/89h/2ff68a52-5b5b-4a22-8f40-c41da8332cfe, doi:10.2905/2FF68A52-5B5B-4A22-8F40-C41DA8332CFE
