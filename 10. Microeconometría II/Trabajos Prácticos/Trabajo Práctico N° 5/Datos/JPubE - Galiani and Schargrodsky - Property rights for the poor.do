clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 5/Datos"

snapshot erase _all
dis _newline(200)

capture log close
log using "JPubE - Galiani and Schargrodsky - Property rights for the poor", replace

*** Arma el matching dentro de los dataset (más de esto en la unidad de matching)
	run "JPubE - Galiani and Schargrodsky - Property rights for the poor - Matching datasets.do"

*** Table 1
	use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investment", clear
	* Panel A
	ttest distanceToCreek if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest distToNonSquatted if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest parcelSurface if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest blockCorner if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch

	* Panel B
	ttest ageOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest femaleOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educationYearsOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatterFather if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educYearsOrigSquatterFather if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatterMother if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educYearsOrigSquatterMother if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch

****************************************************************************************************

log off
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducationOfTheFather==.
replace educYearsOrigSquatterFather=0 if levelEducationOfTheFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducationOfTheMother==.
replace educYearsOrigSquatterMother=0 if levelEducationOfTheMother==.
snapshot save, label("Investment dataset (#1)")
log on

	*** Table 2
		ttest householdArrivedBefore1986 if (repeatedParcel==0 & neighborhood<5), by (propertyOffer) unequal welch
		ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferLate==0 & neighborhood<5), by (propertyOffer) unequal welch
		ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferEarly==0 & neighborhood<5), by (propertyOffer) unequal welch

*** Table 3
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter argentinaFatherOsMiss educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother argentinaMotherOsMiss educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum goodWalls if e(sample) & propertyRight==0
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum goodRoof if e(sample) & propertyRight==0
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum constructedSurface if e(sample) & propertyRight==0
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum concreteSidewalk if e(sample) & propertyRight==0
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum overallHousingAppearance if e(sample) & propertyRight==0
	
**** Table 4
	* col 1
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg goodWalls propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* col 6
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* col 7
	reg goodWalls propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	ivreg goodWalls (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg goodWalls propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	test propertyRightEarly=propertyRightLate
	* col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", clear
		drop if goodWalls == .
		set seed 1
	atts goodWalls propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* col 11
	snapshot restore 1
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.

****************************************************************************************************

log off
use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSize", clear
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducationOfTheFather==.
replace educYearsOrigSquatterFather=0 if levelEducationOfTheFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducationOfTheMother==.
replace educYearsOrigSquatterMother=0 if levelEducationOfTheMother==.
snapshot save, label("Household size dataset (#2)")
log on

*** Table 5
	* reg 1
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum householdSize if e(sample) & propertyRight==0
	* reg 2
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum spouse if e(sample) & propertyRight==0
	* reg 3
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrensMoreThan14 if e(sample) & propertyRight==0
	* reg 4
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberOtherRelatives if e(sample) & propertyRight==0
	* reg 5
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrens5_13 if e(sample) & propertyRight==0
	* reg 6
	reg numberChildrens5_13 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrens5_13 if e(sample) & propertyRight==0
	* reg 7
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrens0_4 if e(sample) & propertyRight==0
	* reg 8
	reg numberChildrens0_4 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrens0_4 if e(sample) & propertyRight==0

****************************************************************************************************

log off
use "JPubE - Galiani and Schargrodsky - Property rights for the poor - education", clear
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducationOfTheFather==.
replace educYearsOrigSquatterFather=0 if levelEducationOfTheFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducationOfTheMother==.
replace educYearsOrigSquatterMother=0 if levelEducationOfTheMother==.
snapshot save, label("Education dataset, full sample (#3)")
log on

*** Table 6
	* col 1
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum schoolAchievement if e(sample) & propertyRight==0
	* col 2
	reg schoolAchievement propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum schoolAchievement if e(sample) & propertyRight==0
	* col 3
	keep if childAge>=13 & childAge<21
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum primarySchoolCompletion if e(sample) & propertyRight==0
	* col 4
	reg primarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum primarySchoolCompletion if e(sample) & propertyRight==0
	* col 5
	keep if childAge>=18 & childAge<21
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum secondarySchoolCompletion if e(sample) & propertyRight==0
	* col 6
	reg secondarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum secondarySchoolCompletion if e(sample) & propertyRight==0
	* col 7
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum postSecondaryEducation if e(sample) & propertyRight==0
	* col 8
	reg postSecondaryEducation propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	sum postSecondaryEducation if e(sample) & propertyRight==0

*** Table 7
	snapshot restore 2
	* col 1
	reg creditCardBankAccount propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum creditCardBankAccount if e(sample) & propertyRight==0
	* col 2
	reg nonMortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum nonMortgageLoan if e(sample) & propertyRight==0
	* col 3
	reg informalCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum informalCredit if e(sample) & propertyRight==0
	* col 4
	reg groceryStoreCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum groceryStoreCredit if e(sample) & propertyRight==0
	* col 5
	reg mortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum mortgageLoan if e(sample) & propertyRight==0
	* col 6
	reg mortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum mortgageLoan if e(sample) & propertyRight==0

*** Table 8
	* col 1
	reg householdHeadIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum householdHeadIncome if e(sample) & propertyRight==0
	* col 2
	reg totalHouseholdIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum totalHouseholdIncome if e(sample) & propertyRight==0
	* col 3
	reg totalHouseholdIncomePerCapita propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum totalHouseholdIncomePerCapita if e(sample) & propertyRight==0
	* col 4
	reg totalHouseholdIncomePerAdult propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum totalHouseholdIncomePerAdult if e(sample) & propertyRight==0
	* col 5
	reg employedHouseholdHead propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
	sum employedHouseholdHead if e(sample) & propertyRight==0

*** Table A.1
	snapshot restore 1	
	* col 1
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg goodRoof propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* col 6
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* col 7
	reg goodRoof propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	ivreg goodRoof (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg goodRoof propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	test propertyRightEarly=propertyRightLate
	* col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", clear
		drop if goodRoof == .
		set seed 1
	atts goodRoof propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* col 11
	snapshot restore 1
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.

*** Table A.2
	* col 1
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg constructedSurface propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* col 6
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* col 7
	reg constructedSurface propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	ivreg constructedSurface (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg constructedSurface propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	test propertyRightEarly=propertyRightLate
	* col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", clear
		drop if constructedSurface == .
		set seed 1
	atts constructedSurface propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* col 11
	snapshot restore 1
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.

*** Table A.3
	* col 1
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg concreteSidewalk propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* col 6
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* col 7
	reg concreteSidewalk propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	ivreg concreteSidewalk (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg concreteSidewalk propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	test propertyRightEarly=propertyRightLate
	* col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", clear
		drop if concreteSidewalk == .
		set seed 1
		atts concreteSidewalk propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* col 11
	snapshot restore 1
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.

*** Table A.4
	* col 1
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg overallHousingAppearance propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* col 6
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* col 7
	reg overallHousingAppearance propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	ivreg overallHousingAppearance (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg overallHousingAppearance propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	test propertyRightEarly=propertyRightLate
	* col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - investmentMatching.dta", clear
		drop if overallHousingAppearance == .
		set seed 1
	atts overallHousingAppearance propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* col 11
	snapshot restore 1
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.

*** Table A.5
	* col 1
	reg hasRefrigetratorWithFreezer propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
	* col 2
	reg hasRefrigetratorWithoutFreezer propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
	* col 3
	reg laundryMachine propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
	* col 4
	reg hasTv propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
	* col5
	reg hasCellularPhone propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

*** Table A.6
	snapshot restore 2
	* Col 1
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg householdSize propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg householdSize propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg householdSize (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg householdSize propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if householdSize == .
		set seed 1
	atts householdSize propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.7
	snapshot restore 2
	* Col 1
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg spouse propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg spouse propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg spouse (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg spouse propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if spouse == .
		set seed 1
	atts spouse propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.8
	snapshot restore 2
	* Col 1
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg numberChildrensMoreThan14 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg numberChildrensMoreThan14 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg numberChildrensMoreThan14 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg numberChildrensMoreThan14 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if numberChildrensMoreThan14 == .
		set seed 1
	atts numberChildrensMoreThan14 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.9
	snapshot restore 2
	* Col 1
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg numberOtherRelatives propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg numberOtherRelatives propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg numberOtherRelatives (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg numberOtherRelatives propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if numberOtherRelatives == .
		set seed 1
	atts numberOtherRelatives propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.10
	snapshot restore 2
	* Col 1
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg numberChildrens5_13 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg numberChildrens5_13 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg numberChildrens5_13 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg numberChildrens5_13 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 11
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingEarly", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingLate", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.11
	snapshot restore 2
	* Col 1
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 2
	reg numberChildrens0_4 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 3
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 4
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 5
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
	* Col 6
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
	* Col 7
	ivreg numberChildrens0_4 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 8
	ivreg numberChildrens0_4 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 9
	reg numberChildrens0_4 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatching", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 11
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingEarly", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - householdSizeMatchingLate", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.12
	snapshot restore 3
	keep if childAge>=6 & childAge<21
	* Col 1
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 2
	reg schoolAchievement propertyRight male childAge
	* Col 3
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
	* Col 4
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
	* Col 5
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
	* Col 6
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
	* Col 7
	reg schoolAchievement propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 8
	ivreg schoolAchievement (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 9
	reg schoolAchievement propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7507662
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 11
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.6363688
		drop if propensityScore>0.7507662
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7088112
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	
*** Table A.13
	snapshot restore 3
	keep if childAge>=13 & childAge<21
	* Col 1
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 2
	reg primarySchoolCompletion propertyRight male childAge
	* Col 3
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
	* Col 4
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
	* Col 5
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
	* Col 6
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
	* Col 7
	reg primarySchoolCompletion propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 8
	ivreg primarySchoolCompletion (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 9
	reg primarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

	* Col 11 (version in published paper)
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=12 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	
	* Col 11 (version with corrected age interval)
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)	
	
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7088112
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	
*** Table A.14
	snapshot restore 3
	keep if childAge>=18 & childAge<21
	* Col 1
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 2
	reg secondarySchoolCompletion propertyRight male childAge
	* Col 3
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
	* Col 4
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
	* Col 5
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
	* Col 6
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
	* Col 7
	reg secondarySchoolCompletion propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 8
	ivreg secondarySchoolCompletion (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 9
	reg secondarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 11
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7014628
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.15
	snapshot restore 3
	keep if childAge>=18 & childAge<21
	* Col 1
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 2
	reg postSecondaryEducation propertyRight male childAge
	* Col 3
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
	* Col 4
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
	* Col 5
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
	* Col 6
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
	* Col 7
	reg postSecondaryEducation propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 8
	ivreg postSecondaryEducation (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 9
	reg postSecondaryEducation propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
	* Col 10
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 11
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
	* Col 12
		use "JPubE - Galiani and Schargrodsky - Property rights for the poor - educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7014628
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)

*** Table A.16
	snapshot restore 2
	* col 1
	reg creditCardBankAccount propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg creditCardBankAccount propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg nonMortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg nonMortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg informalCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 6
	reg informalCredit propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 7
	reg groceryStoreCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	reg groceryStoreCredit propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg mortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 10
	reg mortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

*** Table A.17
	* col 1
	reg householdHeadIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 2
	reg householdHeadIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 3
	reg totalHouseholdIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 4
	reg totalHouseholdIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 5
	reg totalHouseholdIncomePerCapita propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 6
	reg totalHouseholdIncomePerCapita propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 7
	reg totalHouseholdIncomePerAdult propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 8
	reg totalHouseholdIncomePerAdult propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 9
	reg employedHouseholdHead propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	* col 10
	reg employedHouseholdHead propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss femaleOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

****************************************************************************************************
log close