;*************************************************
; Precip_forcing_files.ncl
;
; Specify model precip forcing
; Save as netcdf
; AFP 23 June 2021  
;************************************************
begin	

	; Input file for correct model grid	
	inDust = addfile("/g/data/access/payu/access-esm/input/pre-industrial/ocean/pre-industrial/dust.nc", "r")
	dustIn = inDust->dust	
	latIn = inDust->y_T
	lonIn = inDust->x_T								

	; Let's add a comparable amount to faf-antwater
	mwSv = 0.1		; Sv
	mwM3S = mwSv * 1e6 	; m3 s-1
	dens = 1000.		; kg m-3
	mwKgS = dens * mwM3S 	; kg s-1

	; Divide by area volume will be spread over
	mwCells = dustIn(0,:,:) * 0.
	
	third = 1./3
	sixth = 1./6

	; Circumpolar
	;lon1 = 1
	;lon2 = 358
	;coastLoopNum = 0

	; West Antarctica
	; Lons 160E to 360E
	;lon1 = 80
	;lon2 = 279
	;coastLoopNum = 0

	; East Antarctic
	lon1 = 1
	lon2 = 79
	coastLoopNum = 1

coastFW = True
if (coastFW)

do ifw = 0, coastLoopNum
	
	if (ifw .eq. 1) ; For second iteration of East Antarctic
		lon1 = 280
		lon2 = 358
	end if

	; First, assign cells immediately adjacent to the coast
	do ilon = lon1-1, lon2+1
	do ilat = 1, 40
		if (ismissing(mwCells(ilat-1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
			mwCells(ilat, ilon) = 0.5
		end if
	end do 
	do ilat = 1, 40
		if (ismissing(mwCells(ilat+1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
			mwCells(ilat, ilon) = 0.5
		end if
	end do 
	end do

	do ilat = 1, 40
	do ilon = lon1, lon2+1
		if (ismissing(mwCells(ilat, ilon-1)) .and. .not.ismissing(mwCells(ilat, ilon)))
			mwCells(ilat, ilon) = 0.5
		end if
	end do
	do ilon = lon1-1, lon2
		if (ismissing(mwCells(ilat, ilon+1)) .and. .not.ismissing(mwCells(ilat, ilon)))
			mwCells(ilat, ilon) = 0.5
		end if
	end do
	end do

	; Second, assign cells next to 0.5 cells
	do ilon = lon1-1, lon2+1
	do ilat = 1, 40
		if (.not.ismissing(mwCells(ilat-1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat-1, ilon).eq.0.5 .and. mwCells(ilat, ilon).eq.0.)
			mwCells(ilat, ilon) = third
		end if
		end if
	end do
	do ilat = 1, 40
		if (.not.ismissing(mwCells(ilat+1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat+1, ilon).eq.0.5 .and. mwCells(ilat, ilon).eq.0.)
			mwCells(ilat, ilon) = third
		end if
		end if
	end do
	end do

	do ilat = 1, 40
	do ilon = lon1, lon2+1
		if (.not.ismissing(mwCells(ilat, ilon-1)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat, ilon-1).eq.0.5 .and. mwCells(ilat, ilon).eq.0)
			mwCells(ilat, ilon) = third
		end if
		end if
	end do 
	do ilon = lon1-1, lon2
		if (.not.ismissing(mwCells(ilat, ilon+1)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat, ilon+1).eq.0.5 .and. mwCells(ilat, ilon).eq.0)
			mwCells(ilat, ilon) = third
		end if
		end if
	end do 
	end do

	; Repeat for last cells
	do ilon = lon1-1, lon2+1
	do ilat = 1, 40
		if (.not.ismissing(mwCells(ilat-1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat-1, ilon).eq.third .and. mwCells(ilat, ilon).eq.0.)
			mwCells(ilat, ilon) = sixth
		end if
		end if
	end do
	do ilat = 1, 40
		if (.not.ismissing(mwCells(ilat+1, ilon)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat+1, ilon).eq.third .and. mwCells(ilat, ilon).eq.0.)
			mwCells(ilat, ilon) = sixth
		end if
		end if
	end do
	end do

	do ilat = 1, 40
	do ilon = lon1, lon2+1
		if (.not.ismissing(mwCells(ilat, ilon-1)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat, ilon-1).eq.third .and. mwCells(ilat, ilon).eq.0)
			mwCells(ilat, ilon) = sixth
		end if
		end if
	end do 
	do ilon = lon1-1, lon2
		if (.not.ismissing(mwCells(ilat, ilon+1)) .and. .not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat, ilon+1).eq.third .and. mwCells(ilat, ilon).eq.0)
			mwCells(ilat, ilon) = sixth
		end if
		end if
	end do 
	end do
end do ; ifw loop

end if ; coastFW loop

spreadFW = False
if (spreadFW)
	; And finally, fill cells in lon range and north to 64S as 1/6
	do ilon = lon1, lon2
	do ilat = 0, 42 ; 42 for 60S ; 36 for 64S
		if (.not.ismissing(mwCells(ilat, ilon)))
		if (mwCells(ilat, ilon) .eq. 0)
			mwCells(ilat, ilon) = sixth
		end if
		end if
	end do
	end do	
end if ; spreadFW loop
	
	; Now spread mw across grid cells
	inGrid = addfile("/g/data/access/payu/access-esm/input/pre-industrial/ocean/common/grid_spec.nc", "r")
	area = inGrid->area_T ; m2
	mwArea = mwCells * area
	mwAreaSum = sum(mwArea)
	mwKgSPerCell = mwKgS / mwAreaSum ; kg m-2 s-1

	; Check!
	check_mwKgS = mwKgSPerCell * mwArea
	check_mwKgSsum = sum(check_mwKgS)
	check_mwKgSsum_conv = check_mwKgSsum * 365.25 * 24. * 60. * 60. / 1e3 / 1e9
	print("MW forcing = " + check_mwKgSsum_conv + " Gt y-1")

	; Specify forcing
	pmeCorr = dustIn							; match model output
	pmeCorr = 0.								; zero for all grid cells
	pmeCorr = conform_dims(dimsizes(pmeCorr), mwCells*mwKgSPerCell, (/1,2/))
	pmeCorr = where(ismissing(dustIn), pmeCorr@_FillValue, pmeCorr)		; flag land as missing	

	; Update metadata
	pmeCorr@long_name = "Southern Ocean precipitation minus evaporation correction"
	pmeCorr@units = "kg m-2 s-1"
	printVarSummary(pmeCorr)

	; Save file
	saveFile = addfile("pme_sfc_correction_East_Antarctic_220926.nc", "c")					
	dimNames = (/"time", "grid_y_T", "grid_x_T"/)
	dimSizes = (/dimsizes(pmeCorr&time), dimsizes(pmeCorr&grid_y_T), dimsizes(pmeCorr&grid_x_T)/)
	dimUnlim = (/True, False, False/)
	filedimdef(saveFile, dimNames, dimSizes, dimUnlim)
	saveFile@title = "Precip forcing for ACCESS-ESM1.5 runs, A. Purich"
	saveFile@date = systemfunc("date")
	saveFile->pme = pmeCorr
end
