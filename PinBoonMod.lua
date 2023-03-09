-- Separate Gods from Goddess to add more gods

if ModUtil ~= nil then
	ModUtil.Mod.Register("PinBoonMod")
	local MyLocalizationData = ModUtil.Entangled.ModData(LocalizationData)
	MyLocalizationData.TraitTrayScripts.DetailsBacking.OnPressedFunctionName = "BoonInfoButtonPressed"
	--[[ModUtil.Path.Wrap("CheckLastStand",
		function(baseFunc, victim, triggerArgs)
		
		end
	)]]
	function BoonInfoButtonPressed(screen, button)
		if GameState.PinBoons == nil then
			GameState.PinBoons = {}
		end
		if GameState.PinBoons[button.TraitName] == nil then
			if BoonInfoScreenData.TraitRequirementsDictionary[button.TraitName] then
				GameState.PinBoons[button.TraitName] = {}
			else
				GameState.PinBoons[button.TraitName] = {}
			end
			AddPin(button.Index, ScreenAnchors.BoonInfoScreen.Components)		
			--ModUtil.Hades.PrintStackChunks(ModUtil.ToString("Button on: "..button.TraitName))
		else
			GameState.PinBoons[button.TraitName] = nil
			RemovePin(button.Index, ScreenAnchors.BoonInfoScreen.Components)
			--ModUtil.Hades.PrintStackChunks(ModUtil.ToString("Button off: "..button.TraitName))
		end
		--ModUtil.Hades.PrintStackChunks(ModUtil.ToString.TableKeys(BoonInfoScreenData.TraitRequirementsDictionary))		
	end
	ModUtil.Path.Wrap("ShowBoonInfoScreen",
		function(baseFunc, lootName)
			baseFunc(lootName)
		end
	)
	ModUtil.Path.Wrap("CreateBoonInfoButton",
		function(baseFunc, traitName, index)
			baseFunc(traitName,index);
			local components = ScreenAnchors.BoonInfoScreen.Components
			local offset = { X = -50, Y = -400 + index * BoonInfoScreenData.ButtonYSpacer }
			components["BoonPinButton"..index] = CreateScreenComponent({ Name = "BoonSlot1", Scale = 0.2, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = "Combat_Menu_TraitTray_Backing" })
			Attach({ Id = components["BoonPinButton"..index].Id, DestinationId = components.ShopBackground.Id, OffsetX = offset.X, OffsetY = offset.Y })	
			components["BoonPinButton"..index].OnPressedFunctionName = "BoonInfoButtonPressed"
			components["BoonPinButton"..index].TraitName = traitName
			components["BoonPinButton"..index].Index = index
			CreateTextBox({ Id = components["BoonPinButton"..index].Id, Text = "Toggle",
				FontSize = 22, OffsetX = 0, OffsetY = 0, Width = 720, Font = "AlegreyaSansSCLight",
				ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2}, Justification = "Center"
			})
			components["BoonPin"..index] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray", X = 180, Y = offset.Y + 450,})
			if GameState.PinBoons ~= nil and GameState.PinBoons[traitName] ~= nil then
				AddPin(index, ScreenAnchors.BoonInfoScreen.Components)
			else
				RemovePin(index, ScreenAnchors.BoonInfoScreen.Components)
			end
		end
	)
	function AddPin(index, components)
		SetAnimation({ DestinationId = components["BoonPin"..index].Id, Name = "TraitPinIn_NoHighlight" })
	end
	function RemovePin(index, components)
		SetAnimation({ DestinationId = components["BoonPin"..index].Id, Name = "TraitPinOut_NoHighlight" })

	end

	ModUtil.Path.Wrap("UpdateBoonInfoButtons",
		function(baseFunc, screen)
			baseFunc(screen)		
			local components = ScreenAnchors.BoonInfoScreen.Components	
			local numDisplayed = 1
			for i = screen.StartingIndex, screen.StartingIndex + BoonInfoScreenData.NumPerPage - 1 do 
				local traitName = screen.SortedTraitIndex[i]
				components["BoonPinButton"..numDisplayed].TraitName = traitName
				if  GameState.PinBoons ~= nil and GameState.PinBoons[traitName] ~= nil then
					AddPin(numDisplayed, ScreenAnchors.BoonInfoScreen.Components)
				else
					RemovePin(numDisplayed, ScreenAnchors.BoonInfoScreen.Components)
				end
				numDisplayed = numDisplayed + 1
			end
		end
	)
	ModUtil.Path.Wrap("CreateBoonLootButtons",
		function(baseFunc, lootData, reroll)
			baseFunc(lootData, reroll)
			local traitList = nil
			if GameState.PinBoons ~= nil then
				local tempList = {}
				for traitName, data in pairs( GameState.PinBoons ) do
					if not HeroHasTrait( traitName ) then						
						tempList[traitName] = true
					end
				end
				traitList = GetAllKeys( tempList )
			end
			if traitList ~= nil then
				local components = ScreenAnchors.ChoiceScreen.Components
				--ModUtil.Hades.PrintStackChunks(ModUtil.ToString.TableKeys(components))
				--ModUtil.Hades.PrintStackChunks(ModUtil.ToString(components["PurchaseButton1"].UpgradeName))
				for i = 1, 3 do 
					if components["PurchaseButton"..i] ~= nil and components["PurchaseButton"..i].Data ~= nil then
						local traitName = components["PurchaseButton"..i].Data.Name
						if Contains(traitList, traitName) then
							components["BoonPin"..i] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu", X = 590, Y = 100+i*220,})
							SetAnimation({ DestinationId = components["BoonPin"..i].Id, Name = "TraitPinIn_NoHighlight" })
						end
						--ModUtil.Hades.PrintStackChunks(ModUtil.ToString.TableKeys(components["BoonSlot1"].UpgradeData))
					end
				end
			end
			--[[if GameState.PinBoons ~= nil and GameState.PinBoons[traitName] ~= nil then
				AddPin(index)
			else
				RemovePin(index)
			end]]
		end
	)
	function RequirementListFromTrait(traitName)
		local traitList = {}
		--[[if BoonInfoScreenData.TraitRequirementsDictionary[traitName] then
			local requirement = BoonInfoScreenData.TraitRequirementsDictionary[traitName]
			if requirement.OneOf ~= nil then
				for traitName in requirement.OneOf do
					ModUtil.Hades.PrintStackChunks(ModUtil.ToString(traitName))									
				end					
			end			
			if requirement.OneFromEachSet ~= nil then
				for i, list in ipair(requirement.OneFromEachSet) do
					for traitName in list do
						ModUtil.Hades.PrintStackChunks(ModUtil.ToString(traitName))		
					end							
				end						
			end						
		end]]
		return traitList
	end

	ModUtil.Path.Wrap("BeginOpeningCodex",
		function(baseFunc)
			if (not CanOpenCodex()) and IsSuperValid() then
				BuildSuperMeter(CurrentRun, 50)
			end
			--[[if ScreenAnchors.BoonInfoScreen and ScreenAnchors.BoonInfoScreen.Components["BooninfoButton1"].DetailsBacking.Id then
				TeleportCursor({ DestinationId = ScreenAnchors.BoonInfoScreen.Components["BooninfoButton1"].DetailsBacking.Id, ForceUseCheck = true })
			end]]
			--ModUtil.Hades.PrintStackChunks(ModUtil.ToString("Click"))
			--ModUtil.Hades.PrintStackChunks(ModUtil.ToString.TableKeys(BoonInfoScreenData.TraitRequirementsDictionary))
			baseFunc()
		end
	)
end
