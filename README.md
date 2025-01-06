<<<<<<< HEAD
# ReplicationProject

Replication project The Return to Protectionism

This project aims to replicate figures on U.S. import/export tariff rates from "The Return to Protectionism"  by Fajgelbaum et al. (2019),
The Quarterly Journal of Economics, Volume 135, Issue 1, February 2020, Pages 1–55, https://doi.org/10.1093/qje/qjz036

The original replication package (in Stata) with data can be foound at: 
https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/KSOVSE

Replication Project structure: 
- ReplicationProject.jl #Julia module containing all data processing and plotting logic
- README.md # This file - describes the replication steps
- data/
    - analysis/ # Raw or pre-processed .dta data files
    - tmp/ # Temporary data or intermediate files
 
- results/ 
    - main/ # Final replication outputs (figures)
    - appendix/ # Additional outputs
 

Software requirements: 
- Julia (version 1.7 or higher recommended)
- Packages:
    DataFrames.jl
    StatFiles.jl
    Plots.jl
    Statistics

Usage: 
- Clone/download the repo
- Open Julia in the repo and run the following:
    include("ReplicationProject.jl")
    using .ReplicationProject
    ReplicationProject.set_root_directory("/path/to/rtp/")
    ReplicationProject.run()

The script will:
- Load and transform the .dta files
- Create wave-specific tariff variables
- Generate figures in results/main or results/appendix
  
[![Build Status](https://github.com/karinapavlovich/ReplicationProject.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/karinapavlovich/ReplicationProject.jl/actions/workflows/CI.yml?query=branch%3Amain)
=======
# ReplicationProject
>>>>>>> cbdad252815ee83af0acd1501e5745615536e021
