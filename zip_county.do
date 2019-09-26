*** Import and append quarterly zip to county crosswalks ***
* Documentation for these crosswalks is https://www.huduser.gov/portal/datasets/usps_crosswalk.html#codebook 
* county = 5 digit unique 2000 or 2010 census county GEOID consisting of State Fip(#2) + County Fip(#3)

cd "C:\Users\marku\Desktop\zip_county"
filelist , pattern(*.xlsx) save(zip_county.dta) replace 

use "zip_county.dta", clear
local obs = _N
forvalues i=1/`obs' {
		use "zip_county.dta" in `i' , clear
		local f = dirname + "/" + filename
		import excel using "`f'", firstrow case(lower) allstring clear 
		gen source = "`f'"
		tempfile save`i'
		save "`save`i''"
}

use "`save1'", clear
forvalues i=2/`obs' {
	append using "`save`i''" , force
	save zip_county , replace
}

gen year = real(substr(source,16,4)) 
gen m = real(substr(source,14,2)) 
gen q = qofd(dofm(ym(year, m ))) 
format q %tq 
drop g // Someone accidentally left some whitespace in the next column of sourcefile
drop source 
compress 
drop if zip=="" // This drops one row which only contains the sourcefile

* To find out whether(and how big) imperfect match between counties and zip codes is a problem for the particular I'm using, create a count variable that shows number of possible counties for a given zipcode (in that particular quarter)

egen county_num = count(county) , by(zip q)
drop if county_num != 1
*collapse county_num , by(zip q ) 
save zip_county.dta , replace
