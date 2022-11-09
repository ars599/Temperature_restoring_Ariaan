;*************************************************
; Temperature_restoring_file_eqPac_3C.ncl
;
; Specify model temperature restoring
; Save ACCESS-ESM1.5 piControl years in required format
; Save as netcdf
; AFP 26 September 2022
;************************************************
begin	

	; Input file for correct model grid	
	in = addfile("HadISST_sst_climo_01.nc", "r")
	saltIn = in->temp
	delete(in)

	;************************************************
	; Restore masks
	;************************************************

	; SST restoring in Nino 3.4 region, 5S-5N, 190-240E
	msk = saltIn								; match model output
	msk = 0.								; zero for all grid cells - no restore
	;msk(:, :, {-5.5:5.5}, {-170:-120}) = 1.
	msk(:, :, {-5.5:5.5}, {-170:-90}) = 1.					; Extend box further east
	msk = where(ismissing(saltIn), msk@_FillValue, msk)			; flag land as missing	

	; Update metadata
	msk@long_name = "Nino 3.4 region restoring mask"
	msk@units = "mask"
	printVarSummary(msk)

	; Temporarily change time coordinate if want to view in ncview
	;in2 = addfile("sst_esm-piControl1_ocean_month_07011231.nc", "r")
	;msk&TIME = in2->time

	; Save mask file
	; Comment out once done for saving anomaly files below
;	saveFile = addfile("eqPac_restore_mask.nc", "c")
;	saveFile = addfile("eqPacExt_restore_mask.nc", "c")	
;	dimNames = (/"TIME", "DEPTH1_1", "GRID_Y_T", "GRID_X_T"/)
;	dimSizes = (/dimsizes(msk&TIME), dimsizes(msk&DEPTH1_1), dimsizes(msk&GRID_Y_T), dimsizes(msk&GRID_X_T)/)
;	dimUnlim = (/True, False, False, False/)
;	filedimdef(saveFile, dimNames, dimSizes, dimUnlim)
;	saveFile@title = "Restore mask (1=restore, 0=no restore) for equatorial Pacific region for ACCESS runs, A. Purich"
;	saveFile@date = systemfunc("date")
;	saveFile->restore_mask = msk

	;************************************************
	; SST climo restoring
	;************************************************

  runType = "warm" ; choose from warm or cool

; Loop only one year - input piControl climatology
do iy = 0, 0
	sst = new((/12, dimsizes(msk&DEPTH1_1), dimsizes(msk&GRID_Y_T), dimsizes(msk&GRID_X_T)/), double)	
	in2 = addfile("tos_Omon_ACCESS-ESM1-5_piControl_r1i1p1f1_gn_010101-110012_ymonmean.nc", "r")
	sst(:,0,:,:) = (/ in2->tos /)	
	;sst = sst - 273.15 ; convert to C ; already in C
	time = in2->time
	delete(in2)

	; Add +3C and -3C anomalies globally
	; Mask applied so only restoring to Fiji region 
	sstAnom = 0.
	if (runType .eq. "warm")
		sstAnom = 1.5;3.
	end if
	if (runType .eq. "cool")
		sstAnom = -1.5;-3.
	end if
	sst = sst + sstAnom 

	; Update metadata
	sst!0 = "TIME"
	time@calendar = "gregorian"
	sst&TIME = time
	sst!1 = "DEPTH1_1"
	sst&DEPTH1_1 = msk&DEPTH1_1
	sst!2 = "GRID_Y_T"
	sst&GRID_Y_T = msk&GRID_Y_T
	sst!3 = "GRID_X_T"
	sst&GRID_X_T = msk&GRID_X_T
	sst@long_name = "Climatology SST restoring "
	sst@units = "C"
	sst@missing_value = sst@_FillValue
	printVarSummary(sst)
	printVarSummary(sst&TIME)
	delete(time)

	; Save files
	saveFile = addfile("sst_eqPac_" + runType + "_15.nc", "c") ; amend depending on SST anom	
	dimNames = (/"TIME", "DEPTH1_1", "GRID_Y_T", "GRID_X_T"/)
	dimSizes = (/dimsizes(msk&TIME), dimsizes(sst&DEPTH1_1), dimsizes(sst&GRID_Y_T), dimsizes(sst&GRID_X_T)/)
	dimUnlim = (/True, False, False, False/)
	filedimdef(saveFile, dimNames, dimSizes, dimUnlim)
	saveFile@title = runType + " SST restoring for ACCESS runs, A. Purich"
	saveFile@date = systemfunc("date")
	saveVar = (/ sst /)
	copy_VarMeta(msk, saveVar)
	saveVar&TIME@calendar = "gregorian"
	delete(saveVar&TIME@calendar_type)
	year = new(12, integer)
	year = toint(iy)
	month = (/1,2,3,4,5,6,7,8,9,10,11,12/)
	day = new(12, integer)
	day = 14
	hour = new(12, integer)
	hour = 00
	minute = new(12, integer)
	minute = 00
	second = new(12, integer)
	second = 00
	units = saveVar&TIME@units
	newTime = cd_inv_calendar(year, month, day, hour, minute, second, units, 0)
	newTime@calendar = "gregorian"
	saveVar&TIME = newTime
	delete(newTime)
	saveVar@long_name = "ACCESS-ESM1.5 piControl " + runType + " equatorial Pacific SST restoring"
	saveVar@units = "C"
	saveFile->temp = saveVar
	delete([/sst, sstAnom, saveVar/])
end do

end
