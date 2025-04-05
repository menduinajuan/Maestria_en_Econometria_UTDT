version 9

************************************************************************************************************************************************
********************************************** Creates matching dataset for investment *********************************************************
************************************************************************************************************************************************

use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investment", clear
keep if neighborhood <5 & inBothDatasets ==3 & nonSurveyed  ==.

su parcelId
su parcelId if repeatedParcel==0

logit householdArrivedBefore1986 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if repeatedParcel==0
logit householdArrivedBefore1986 parcelSurface distanceToCreek blockCorner distToNonSquatted if repeatedParcel==0
predict propensityScore
label variable propensityScore "Propensity score"

* Stores in a temporal dataset the logit results
preserve
drop if repeatedParcel==1
sort parcelId
tempfile propensityScore
save `propensityScore'
restore

* Sep Stayers
keep if householdArrivedBefore1986 == 1

su propensityScore propertyRight

sort propertyRight
by propertyRight: su propensityScore, detail
su goodWalls goodRoof constructedSurface concreteSidewalk overallHousingAppearance if repeatedParcel == 0 &(propen<0.5381833 | propen>0.7778726)

**** Drop observations outside of common support *****

drop if propensityScore < 0.5381833
drop if propensityScore > 0.7778726

sort propertyRight
by propertyRight: su propensityScore, detail

su propensityScore if propertyRight == 1, detail
gen b1 = r(p10)
gen b2 = r(p25)
gen b3 = r(p50)
gen b4 = r(p75)
gen b5 = r(p90)

su b1-b5

gen matchingBlock = 1 if propensityScore<b1
replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
replace matchingBlock = 5 if propensityScore >=b4 & propensityScore<b5
replace matchingBlock = 6 if propensityScore >=b5

sort matchingBlock propertyRight
by matchingBlock: ttest propensityScore, by(propertyRight) unequal

sort matchingBlock propertyRight
by matchingBlock: ttest parcelSurface, by(propertyRight) unequal  
by matchingBlock: ttest distanceToCreek, by(propertyRight) unequal 
by matchingBlock: ttest blockCorner, by(propertyRight) unequal 
by matchingBlock: ttest distToNonSquatted, by(propertyRight) unequal 
label variable matchingBlock "Block identifier of the estimated propensity score"

* Preserves current state of the dataset for future use in household size matching dataset
preserve

keep if repeatedParcel == 0
sort householdId
keep parcelId householdId propertyRight concreteSidewalk constructedSurface overallHousingAppearance goodWalls goodRoof propensityScore matchingBlock
save "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for education **********************************************************
************************************************************************************************************************************************

use "JPubE - Galiani and Schargrodsky - Property rights for the poor - education", clear

* merges logit results
merge m:1 parcelId using `propensityScore'

keep if _merge == 3
keep schoolAchievement primarySchoolCompletion secondarySchoolCompletion postSecondaryEducation childAge propertyRightEarly propertyRightLate parcelId householdId personId propertyRight propensityScore
save "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size *****************************************************
************************************************************************************************************************************************

use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSize", clear

* Stores households with data in a temporal dataset
sort householdId
keep if householdId != .
tempfile hhSizeNoMissings
save `hhSizeNoMissings'

* Restores the previously preserved dataset in line 71
restore


* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3
keep  parcelId householdId householdSize propertyRight propensityScore matchingBlock numberChildrens5_13 numberChildrens0_4 spouse numberOtherRelatives numberChildrensMoreThan14
save "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size early ***********************************************
************************************************************************************************************************************************


use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investment", clear
keep if neighborhood <5 & inBothDatasets ==3 & nonSurveyed  ==.

logit householdArrivedBefore1986 parcelSurface distanceToCreek blockCorner distToNonSquatted if repeatedParcel==0
predict propensityScore
label variable propensityScore "Propensity score"

* Sep Stayers
keep if householdArrivedBefore1986 == 1

* Keep Early and Control
drop if propertyRightLate == 1

su propensityScore propertyRight
label variable propensityScore "Propensity score"

sort propertyRight
by propertyRight: su propensityScore, detail

* Drop observations outside of common support
drop if propensityScore < 0.6184519
drop if propensityScore > 0.7778726

sort propertyRight
by propertyRight: su propensityScore, detail

su propensityScore if propertyRight == 1, detail

gen b1 = r(p10)
gen b2 = r(p25)
gen b3 = r(p50)
gen b4 = r(p75)
gen b5 = r(p90)

su b1-b5

gen matchingBlock = 1 if propensityScore<b1
replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
replace matchingBlock = 5 if propensityScore >=b4 & propensityScore<b5
replace matchingBlock = 6 if propensityScore >=b5

sort matchingBlock propertyRight
by matchingBlock: ttest propensityScore, by(propertyRight) unequal

sort matchingBlock propertyRight
by matchingBlock: ttest parcelSurface, by(propertyRight) unequal  
by matchingBlock: ttest distanceToCreek, by(propertyRight) unequal 
by matchingBlock: ttest blockCorner, by(propertyRight) unequal 
by matchingBlock: ttest distToNonSquatted, by(propertyRight) unequal 
label variable matchingBlock "Block identifier of the estimated propensity score"

* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3

keep parcelId householdId propertyRight propensityScore matchingBlock numberChildrens5_13 numberChildrens0_4
save "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingEarly", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size late ************************************************
************************************************************************************************************************************************

use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investment", clear
keep if neighborhood <5 & inBothDatasets ==3 & nonSurveyed  ==.

su parcelId
su parcelId if repeatedParcel==0

logit householdArrivedBefore1986 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if repeatedParcel==0
logit householdArrivedBefore1986 parcelSurface distanceToCreek blockCorner distToNonSquatted if repeatedParcel==0
predict propensityScore
label variable propensityScore "Propensity score"

* Sep Stayers
keep if householdArrivedBefore1986 == 1


* Keep Late and Control
drop if propertyRightEarly == 1

su propensityScore propertyRight

sort propertyRight
by propertyRight: su propensityScore, detail
su goodWalls goodRoof constructedSurface concreteSidewalk overallHousingAppearance if repeatedParcel == 0 &(propen<0.5381833 | propen>0.7778726)


* Drop observations outside of common support
drop if propensityScore < 0.5381833
drop if propensityScore > 0.7330715

sort propertyRight
by propertyRight: su propensityScore, detail

su propensityScore if propertyRight == 1, detail
gen b1 = r(p10)
gen b2 = r(p25)
gen b3 = r(p50)
gen b4 = r(p75)
gen b5 = r(p90)

su b1-b5

gen matchingBlock = 1 if propensityScore<b1
replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
replace matchingBlock = 5 if propensityScore >=b4 & propensityScore<b5
replace matchingBlock = 6 if propensityScore >=b5

sort matchingBlock propertyRight
by matchingBlock: ttest propensityScore, by(propertyRight) unequal
sort matchingBlock propertyRight
by matchingBlock: ttest parcelSurface, by(propertyRight) unequal  
by matchingBlock: ttest distanceToCreek, by(propertyRight) unequal 
by matchingBlock: ttest blockCorner, by(propertyRight) unequal 
by matchingBlock: ttest distToNonSquatted, by(propertyRight) unequal 
label variable matchingBlock "Block identifier of the estimated propensity score"

* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3

keep parcelId householdId propertyRight propensityScore matchingBlock numberChildrens5_13 numberChildrens0_4
save "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingLate", replace