# UK Gender Political Divide Analysis Project

## Project Overview

This project analyzes the ideological gender divide in UK politics for a FTSE 100 CEO who wants to understand how to position her company publicly and track changes over time. The analysis focuses on evidence of gender-based political differences across generations, particularly among young people.

## Business Context

- **Client**: CEO of FTSE 100 company
- **Motivation**: Recent elections (UK, USA, France) show rising support for right-wing parties; CEO has read about growing ideological gap between men and women
- **Business Need**: Evidence-based strategy for public company positioning and ongoing tracking capability
- **Timeline**: 5 days for initial analysis and tracker setup

## Key Research Questions

1. Is there evidence of an ideological gender divide in the UK?
2. How does this divide differ across generations?
3. What can we learn about young people's attitudes to challenge the idea they're a monolith?
4. How can we track changes in these metrics over time?

## Deliverables

1. **Slide Deck**: Max 5 pages with key data visualizations and concise insights
2. **Tracking System**: Automated functions for time-series analysis of future data waves
3. **Code Scripts**: Functionalized Python/R scripts for reproducible analysis

## Data Source

**Dataset**: Focaldata UK Election Study 2024
- **Sample Size**: n=30,000
- **Collection Period**: Few months leading up to July 2024 UK general election
- **Treatment**: Cross-sectional snapshot of public attitudes
- **Weighting**: Nationally representative (age, gender, region, ethnicity, education)

## Variable Descriptions

### Demographics
- `respondent_id`: Unique anonymized ID
- `wt`: National representativity weight (based on age, gender, region, ethnicity, education)
- `age`: Age band
- `gender`: Gender
- `education`: Education level (lower or higher than degree level)
- `ethnicity`: Ethnicity
- `region`: UK NUTS1 region
- `cons_code`: Westminster constituency code
- `cons_name`: Westminster constituency name
- `household`: Household tenure
- `religion`: Religion
- `socgrad`: Social grade classification
- `marital`: Marital status

### Political Variables
- `pv_2019`: 2019 general election vote
- `pv_2024`: 2024 general election voting intention (treated as actual vote)
- `eu_ref`: 2016 Brexit referendum vote

### Attitudinal Variables (Liberal/Authoritarian & Economic Scales)

**Economic Attitudes** (Left-Right spectrum):
- `econ_redist`: "Government should redistribute from better off to less well off"
- `econ_bigbiz`: "Big business take advantage of ordinary people"
- `econ_unfair`: "Ordinary people do not get fair share of nation's wealth"
- `econ_onelaw`: "One law for rich, another for poor"
- `econ_exploit`: "Management will always try to get better of employees"

**Social Attitudes** (Liberal-Authoritarian spectrum):
- `soc_respect`: "Young people don't have enough respect for traditional British values"
- `soc_deathpen`: "Death penalty is most appropriate for some crimes"
- `soc_schools`: "Schools should teach children to obey authority"
- `soc_censor`: "Censorship necessary to uphold moral standards"
- `soc_punish`: "Law breakers should get stiffer sentences"

*Note: All attitudinal variables measured on agree-disagree scale*

## Analysis Approach

### Core Methodology
1. **Descriptive Analysis**: Gender differences across age groups
2. **Comparative Analysis**: Generational differences in gender gaps
3. **Scale Construction**: Create composite liberal/authoritarian and economic scales
4. **Statistical Testing**: Significance tests for gender differences
5. **Segmentation**: Young people analysis to challenge monolithic assumptions

### Key Analytical Considerations
- Use survey weights for all analyses to ensure representativity
- Focus on practical significance alongside statistical significance
- Consider both economic and social dimensions of political attitudes
- Pay special attention to young demographics (likely 18-34 age bands)
- Look for interaction effects between gender and age

### Tracking Functions Requirements
- **Modular Design**: Functions that can process new data waves
- **Automated Outputs**: Standard battery of graphics and metrics
- **Time Series Capability**: Track changes over multiple waves
- **Proof of Concept**: Split current data by month for testing

## Technical Specifications

### Data Format
- **File**: uk_election_data_case_study_weighted.sav (SPSS format)
- **Key ID**: respondent_id
- **Weight Variable**: weight (must be applied to all analyses)

### Expected Outputs
1. **Visualizations**: 
   - Gender differences by age group
   - Trend analysis across generations
   - Young people attitude distributions
   - Time-series ready charts

2. **Metrics to Track**:
   - Gender gap in liberal/authoritarian attitudes by age
   - Gender gap in economic attitudes by age
   - Young people attitude heterogeneity measures
   - Statistical significance indicators

### Function Design Principles
- **Simplicity**: Easy to interpret for business stakeholders
- **Robustness**: Handle missing data and edge cases
- **Flexibility**: Adaptable to new waves with different sample sizes
- **Reproducibility**: Consistent results across runs

## Reference Materials
- FT article on global gender divide (provided)
- British Election Study historical questions (same attitudinal measures)
- Academic literature on political attitude measurement

## Success Criteria
- Clear evidence on UK gender political divide
- Actionable insights for corporate positioning
- Functional tracking system for ongoing monitoring
- Business-ready presentation format

## Notes for Implementation
- Prioritize clarity over complexity in statistical methods
- Focus on business implications of findings
- Ensure all code is well-documented for handover
- Test tracking functions with subset of data before full implementation

### Unique values for categorical variables

$age
[1] "25_TO_34" "18_TO_24" "55_TO_64" "35_TO_44" "65_TO_74" "75_PLUS"  "45_TO_54"

$gender
[1] "male"   "female"

$education
[1] "low"  "high"

$ethnicity
[1] "white" "other" "asian" "black" "mixed"

$region
 [1] "East of England"          "South West England"       "South East England"      
 [4] "West Midlands"            "Scotland"                 "North West England"      
 [7] "Wales"                    "Greater London"           "Yorkshire and the Humber"
[10] "East Midlands"            "North East England"      

$household
[1] "owns_with_mortgage_or_shared" "private_rented_or_rent_free" 
[3] "social_rented"                "owns_outright"               

$religion
[1] "none"      "christian" "muslim"    "hindu"     "other"     NA         

$socgrad
[1] "C2" "AB" "DE" "C1"

$marital
[1] "relationship_notliving" "single"                 "relationship_living"   
[4] "widowed"                "married_civil"          "separated_divorced"    
[7] NA                      

$pv_2019
[1] "dnv" "ldm" "con" "brx" "snp" "lab" "grn" "oth" "pcy"

$pv_2024
[1] "rfm" "lab" "con" "grn" "wnv" "ldm" "snp" "oth" "pcy"

$eu_ref
[1] "leave"  "dnv"    "remain" NA      


