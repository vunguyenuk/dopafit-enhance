import Foundation
@main struct ModelChecks {
    @MainActor static func main() throws {
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent("dopafit-model-checks-"+UUID().uuidString)
        defer{try? FileManager.default.removeItem(at:dir)}
        let url=dir.appendingPathComponent("state.json")
        let s=AppStore(storageURL:url)
        var passed=0
        func check(_ value:Bool,_ name:String){passed+=1;if !value{fatalError("FAIL: "+name)};print("PASS: "+name)}
        check(s.data.draft?.exercises.count==7,"initial plan contains seven exercises")
        s.start()
        let start=s.data.draft!.started
        s.start()
        check(s.data.draft!.started==start,"resuming does not reset workout start time")
        let id=s.data.draft!.exercises[1].id
        let setID=s.data.draft!.exercises[1].sets[0].id
        s.mutateExercise(id){$0.sets[0].weight=0}
        s.logSet(exercise:id,set:setID)
        check(s.data.draft!.exercises[1].doneCount==0,"zero loaded barbell set rejected")
        s.mutateExercise(id){for i in $0.sets.indices{$0.sets[i].weight=42.5;$0.sets[i].reps=6};$0.rir=2}
        s.logSet(exercise:id,set:setID)
        s.logSet(exercise:id,set:setID,toggle:true)
        check(s.data.draft!.exercises[1].doneCount==0,"undo logged set")
        s.logAll(id)
        check(s.data.draft!.volume==765,"three sets calculate 765 kg volume")
        let restoredDraft=AppStore(storageURL:url)
        check(restoredDraft.data.draft!.exercises[1].doneCount==3,"draft survives storage reload")
        let session=s.finish()!
        check(session.exercises.count==1 && session.exercises[0].sets.count==3,"finish keeps only completed exercise and sets")
        check(session.exercises[0].rir==2,"RIR persists with saved exercise")
        check(session.exercises[0].sets.map(\.estimatedMax).max()==51,"estimated 1RM equals 51 kg")
        check(s.finish()==nil && s.data.history.count==1,"empty next draft cannot duplicate previous workout")
        let reopened=AppStore(storageURL:url)
        check(reopened.data.history.count==1 && reopened.data.history[0].volume==765,"history survives process-like reload")
        check(reopened.muscleSets("Ngực")==3 && reopened.muscleSets("Vai")==1.5 && reopened.muscleSets("Tay sau")==1.5,"primary and secondary muscle set contribution")
        let csv=reopened.csvData()
        check(csv.components(separatedBy:"\n").count==4 && csv.contains("42.5"),"CSV exports all three logged sets")
        reopened.changePlan{$0.unit="lb"}
        check(abs(reopened.kilograms(reopened.displayWeight(42.5))-42.5)<0.000001,"unit conversion round-trip preserves kg data")
        reopened.setPreference("squat",-2)
        reopened.makeDraft(lower:true)
        check(!reopened.data.draft!.exercises.contains{$0.exercise.id=="squat"},"excluded exercise omitted from generated draft")
        reopened.changePlan{$0.warmup=true}
        reopened.makeDraft(lower:false)
        check(reopened.data.draft!.exercises[0].sets.first!.warmup,"warmup setting adds warmup sets")
        reopened.changePlan{$0.warmup=false}
        reopened.makeDraft(lower:false)
        check(reopened.data.draft!.exercises.first{$0.exercise.id=="incline"}!.sets[0].weight==45,"local progression advances completed target to next load")
        reopened.changePlan{$0.ageGroup="25–34";$0.trainingDays=[2,4,6]}
        reopened.data.onboardingAnswers=["4":["Ghi lại tạ và rep"]];reopened.persist()
        let newProfile=AppStore(storageURL:url)
        check(newProfile.data.plan.ageGroup=="25–34" && newProfile.data.plan.trainingDays==[2,4,6],"onboarding profile survives reload")
        check(newProfile.data.onboardingAnswers?["4"]==["Ghi lại tạ và rep"],"onboarding answers survive reload")
        var legacy=try JSONSerialization.jsonObject(with:Data(contentsOf:url)) as! [String:Any]
        legacy.removeValue(forKey:"onboardingAnswers")
        var plan=legacy["plan"] as! [String:Any]
        for key in ["ageGroup","trainingDays","equipmentPreference","otherActivity"]{plan.removeValue(forKey:key)}
        legacy["plan"]=plan
        try JSONSerialization.data(withJSONObject:legacy).write(to:url)
        let migrated=AppStore(storageURL:url)
        check(migrated.data.history.count==1 && migrated.data.history[0].volume==765,"older saved state retains history after profile fields added")
        migrated.changePlan{$0.experience="Mới bắt đầu";$0.minutes=60;$0.warmup=false;$0.split="Thân trên / Thân dưới"}
        migrated.makeDraft(lower:false)
        check(migrated.data.draft!.exercises.count==7 && migrated.data.draft!.exercises[0].exercise.id=="dumbbell-row","beginner plan uses observed seven-exercise prescription")
        let rowID=migrated.data.draft!.exercises[0].id
        let rowSetID=migrated.data.draft!.exercises[0].sets[0].id
        check(migrated.data.draft!.exercises[0].sets[0].reps==12 && migrated.data.draft!.exercises[0].sets[0].weight==30,"beginner row starts at observed 12 reps and 30 kg")
        migrated.start();migrated.logSet(exercise:rowID,set:rowSetID)
        let rowSession=migrated.finish()!
        check(rowSession.volume==720 && rowSession.exercises[0].sets[0].estimatedMax==42,"two-sided volume is 720 kg while 1RM stays per-arm 42 kg")
        migrated.updateSavedRIR(sessionID:rowSession.id,exerciseID:rowID,value:3)
        let savedRIR=AppStore(storageURL:url)
        check(savedRIR.data.history.first{$0.id==rowSession.id}!.exercises[0].rir==3,"post-save RIR survives storage reload")
        check(savedRIR.data.history.first{$0.id==rowSession.id}!.volume==720,"post-save RIR does not change logged volume")
        savedRIR.updateSavedRIR(sessionID:rowSession.id,exerciseID:rowID,value:8)
        check(savedRIR.data.history.first{$0.id==rowSession.id}!.exercises[0].rir==4,"saved RIR is bounded to zero through four")
        check(savedRIR.csvData().contains("volume_multiplier,volume_kg") && savedRIR.csvData().contains(",2.0,720.0"),"CSV carries the two-sided volume convention")
        let onlyGym=savedRIR.data.gyms[0].id
        check(!savedRIR.removeGym(onlyGym) && savedRIR.data.gyms.count==1,"last gym cannot be removed")
        savedRIR.renameGym(onlyGym,to:"  Gym test  ")
        check(AppStore(storageURL:url).data.gyms[0].name=="Gym test","gym rename trims and persists")
        savedRIR.renameGym(onlyGym,to:"   ")
        check(savedRIR.data.gyms[0].name=="Gym test","blank gym rename is ignored")
        let extraGym=GymProfile(name:"Home")
        savedRIR.data.gyms.append(extraGym);savedRIR.data.gymID=extraGym.id;savedRIR.persist()
        check(savedRIR.removeGym(extraGym.id) && savedRIR.currentGym.id==onlyGym,"removing selected extra gym selects surviving gym")
        var edited=savedRIR.data.history.first{$0.id==rowSession.id}!.exercises[0]
        edited.sets[0].reps=10;edited.sets[0].weight=25
        check(savedRIR.saveHistoryExercise(sessionID:rowSession.id,item:edited),"saved set editor accepts valid exercise update")
        let updated=AppStore(storageURL:url)
        check(updated.data.history.first{$0.id==rowSession.id}!.volume==500 && updated.data.history.count==2,"saved edits recalculate two-sided volume and survive reload without duplicate session")
        edited.sets[0].reps = -1
        check(!updated.saveHistoryExercise(sessionID:rowSession.id,item:edited) && updated.data.history.first{$0.id==rowSession.id}!.volume==500,"invalid saved edit is rejected without changing history")
        var added=WorkoutExercise(Catalog.upper[1]);added.sets=Array(added.sets.prefix(1))
        check(updated.saveHistoryExercise(sessionID:rowSession.id,item:added) && updated.data.history.first{$0.id==rowSession.id}!.exercises.count==2,"add an exercise to saved session without modifying another session")
        updated.removeHistoryExercise(sessionID:rowSession.id,exerciseID:added.id)
        check(updated.data.history.first{$0.id==rowSession.id}!.exercises.count==1,"remove exercise from saved session")
        check(Set(Catalog.all.map(\.id)).count==Catalog.all.count,"Form catalog preserves unique exercise identities")
        check(Catalog.all.contains{$0.id=="dumbbell-shoulder-press"} && Catalog.all.contains{$0.id=="arnold"},"plain dumbbell shoulder press remains distinct from Arnold press")
        check(Set(updated.exercises(query:"dumbbell row",gear:"Cặp tạ đơn").map(\.id))==Set(["dumbbell-row","bent-over-dumbbell-row"]),"exercise search combines English name and equipment")
        check(updated.exercises(sort:"Tập nhiều nhất").first!.id=="incline","most-trained sort uses logged set counts")
        check(updated.exercises(sort:"Chưa tập").allSatisfy{updated.exerciseHistory($0.id).isEmpty},"untrained filter excludes logged exercises")
        var templateExercise=WorkoutExercise(Catalog.beginnerUpper[0])
        templateExercise.sets=[LoggedSet(reps:11,weight:17.5,completed:true)];templateExercise.rir=3;templateExercise.restSeconds=90
        let template=SavedWorkout(name:"Custom target",exercises:[templateExercise]);updated.data.saved.append(template)
        updated.loadTemplate(template.id)
        check(updated.data.draft!.exercises[0].sets[0].reps==11 && updated.data.draft!.exercises[0].sets[0].weight==17.5 && updated.data.draft!.exercises[0].restSeconds==90,"saved template restores custom reps load and rest")
        check(updated.data.draft!.completedSets==0 && updated.data.draft!.exercises[0].rir==nil && updated.data.draft!.exercises[0].sets[0].id != templateExercise.sets[0].id,"template reuse clears completion RIR and set identifiers")
        updated.dismissTip("goals");updated.dismissTip("goals")
        check(AppStore(storageURL:url).data.dismissedTips==["goals"],"dismissed UI tip persists without duplicates")
        let timedID=updated.data.draft!.exercises[0].id
        updated.mutateExercise(timedID){$0.restSeconds=90;$0.warmupRestSeconds=20;$0.sets[0].warmup=true}
        updated.logSet(exercise:timedID,set:updated.data.draft!.exercises[0].sets[0].id)
        check(abs(updated.timerEnd!.timeIntervalSinceNow-20)<2,"warmup set uses its separate rest duration")
        updated.mutateExercise(timedID){$0.sets[0].warmup=false;$0.sets[0].completed=false}
        updated.logSet(exercise:timedID,set:updated.data.draft!.exercises[0].sets[0].id)
        check(abs(updated.timerEnd!.timeIntervalSinceNow-90)<2,"working set retains its own rest duration")
        updated.adjustRecovery(["Ngực":0,"Lưng":120,"Vai":-5])
        check(updated.muscleRecovery("Ngực")==0 && updated.muscleRecovery("Lưng")==100 && updated.muscleRecovery("Vai")==0,"manual recovery is bounded between zero and one hundred")
        let manualReload=AppStore(storageURL:url)
        check(manualReload.muscleRecovery("Ngực")==0,"manual recovery survives reload on the same day")
        manualReload.makeDraft(lower:false)
        check(!manualReload.data.draft!.exercises.contains{$0.exercise.muscles.contains("Ngực")||$0.exercise.muscles.contains("Vai")},"zero recovery muscles are omitted when generating a new plan")
        manualReload.data.recoveryAdjustment?.date=Calendar.current.date(byAdding:.day,value:-1,to:Date())!
        check(manualReload.manualRecovery("Ngực")==nil,"local manual recovery override expires on the next day")
        let beforeDuration=manualReload.data.history.first{$0.id==rowSession.id}!.duration
        check(!manualReload.updateSavedDuration(sessionID:rowSession.id,hours:0,minutes:0) && manualReload.data.history.first{$0.id==rowSession.id}!.duration==beforeDuration,"zero duration edit leaves saved session unchanged")
        check(!manualReload.updateSavedDuration(sessionID:rowSession.id,hours:1,minutes:60),"invalid minute component is rejected")
        check(manualReload.updateSavedDuration(sessionID:rowSession.id,hours:1,minutes:17),"hour and minute duration edit is accepted")
        let durationReload=AppStore(storageURL:url)
        check(durationReload.data.history.first{$0.id==rowSession.id}!.duration==4620 && durationReload.data.history.first{$0.id==rowSession.id}!.volume==500,"duration edit persists without changing logged volume")
        let discardEncoder=JSONEncoder();discardEncoder.outputFormatting = .sortedKeys
        let retainedHistory=try discardEncoder.encode(durationReload.data.history)
        let retainedTemplates=try discardEncoder.encode(durationReload.data.saved)
        let retainedSplit=durationReload.data.lowerNext
        durationReload.start()
        let abandonedID=durationReload.data.draft!.id
        let abandonedExercise=durationReload.data.draft!.exercises[0].id
        durationReload.logAll(abandonedExercise)
        durationReload.timerEnd=Date().addingTimeInterval(120);durationReload.timerExercise=abandonedExercise;durationReload.pausedRest=30
        durationReload.discardWorkout()
        check(durationReload.data.draft!.id != abandonedID && !durationReload.data.draft!.hasStarted && durationReload.data.draft!.completedSets==0,"discard creates an unstarted draft without logged sets")
        check(durationReload.timerEnd==nil && durationReload.timerExercise==nil && durationReload.pausedRest==nil && !durationReload.showingActive,"discard clears running and paused rest state")
        let historyAfterDiscard=try discardEncoder.encode(durationReload.data.history)
        let templatesAfterDiscard=try discardEncoder.encode(durationReload.data.saved)
        check(historyAfterDiscard==retainedHistory && templatesAfterDiscard==retainedTemplates && durationReload.data.lowerNext==retainedSplit,"discard preserves saved history templates and split")
        let discardedReload=AppStore(storageURL:url)
        check(discardedReload.data.draft!.id==durationReload.data.draft!.id && discardedReload.data.draft!.completedSets==0 && !discardedReload.data.draft!.hasStarted,"discarded draft state survives reload")
        let grouping=AppStore(storageURL:dir.appendingPathComponent("grouping.json"))
        grouping.start()
        let originalGroupDraft=grouping.data.draft!
        let ids=originalGroupDraft.exercises.map(\.id)
        grouping.logAll(ids[0])
        let loggedBeforeGroup=grouping.data.draft!.completedSets
        let planSupersetsBefore=grouping.data.plan.supersets
        check(!grouping.groupDraftExercises([ids[0]]) && !grouping.groupDraftExercises([ids[0],UUID()]) && grouping.data.draft!.exercises.allSatisfy{$0.supersetID==nil},"superset rejects fewer than two or unknown exercise IDs without mutation")
        check(grouping.groupDraftExercises([ids[0],ids[2]]) && grouping.data.draft!.exercises[0].supersetID==grouping.data.draft!.exercises[1].supersetID && grouping.data.draft!.exercises[0].supersetID != nil,"superset saves one shared group on selected exercises")
        check(grouping.data.draft!.exercises.map(\.id)==[ids[0],ids[2],ids[1]]+Array(ids.dropFirst(3)) && grouping.data.draft!.completedSets==loggedBeforeGroup && grouping.data.draft!.started==originalGroupDraft.started && grouping.data.plan.supersets==planSupersetsBefore && grouping.data.history.isEmpty,"superset groups nonadjacent items together preserving member/rest order and logged data")
        let groupReload=AppStore(storageURL:grouping.storageURL)
        check(groupReload.data.draft!.exercises[0].supersetID==groupReload.data.draft!.exercises[1].supersetID && groupReload.data.draft!.completedSets==loggedBeforeGroup,"superset group and logged sets survive reload")
        grouping.groupDraftExercises([ids[0],ids[1]])
        check(grouping.data.draft!.exercises.first{$0.id==ids[2]}!.supersetID==nil && grouping.data.draft!.exercises.first{$0.id==ids[0]}!.supersetID==grouping.data.draft!.exercises.first{$0.id==ids[1]}!.supersetID,"regrouping clears orphan single-exercise groups")
        let groupID=grouping.data.draft!.exercises.first{$0.id==ids[0]}!.supersetID!
        let beforeDuplicate=grouping.data.draft!
        let newGroupID=grouping.duplicateDraftGroup(groupID)!
        let duplicates=grouping.data.draft!.exercises.filter{$0.supersetID==newGroupID}
        check(duplicates.count==2 && Set(duplicates.map(\.id)).isDisjoint(with:Set(beforeDuplicate.exercises.map(\.id))) && Set(duplicates.flatMap(\.sets).map(\.id)).isDisjoint(with:Set(beforeDuplicate.exercises.flatMap(\.sets).map(\.id))),"duplicate group uses fresh group exercise and set identifiers")
        check(duplicates.allSatisfy{$0.doneCount==0 && $0.rir==nil} && grouping.data.draft!.completedSets==beforeDuplicate.completedSets && grouping.data.draft!.started==beforeDuplicate.started && grouping.data.history.isEmpty,"duplicate preserves existing logged data and starts new group unlogged")
        check(grouping.logDraftGroup(newGroupID) && grouping.data.draft!.exercises.filter{$0.supersetID==newGroupID}.allSatisfy{$0.doneCount==$0.sets.count},"group log marks every valid set on its members")
        let detachedOrder=grouping.data.draft!.exercises.map(\.id),detachedSets=grouping.data.draft!.completedSets
        check(grouping.detachDraftGroup(newGroupID) && grouping.data.draft!.exercises.map(\.id)==detachedOrder && grouping.data.draft!.completedSets==detachedSets && grouping.data.draft!.exercises.filter{duplicates.map(\.id).contains($0.id)}.allSatisfy{$0.supersetID==nil},"detach group preserves order and logged sets as observed R79 R82")
        let afterDetach=AppStore(storageURL:grouping.storageURL)
        check(afterDetach.data.draft!.exercises==grouping.data.draft!.exercises && afterDetach.data.history.isEmpty,"duplicate log and detach persist without creating a saved session")
        let invalidSnapshot=try discardEncoder.encode(afterDetach.data.draft)
        check(!afterDetach.detachDraftGroup(UUID()) && afterDetach.duplicateDraftGroup(UUID())==nil && !afterDetach.logDraftGroup(UUID()),"unknown group operations are rejected")
        let afterInvalid=try discardEncoder.encode(afterDetach.data.draft)
        check(invalidSnapshot==afterInvalid,"invalid group operations leave draft unchanged")
        let groupBeforeRemove=afterDetach.data.draft!.exercises.filter{$0.supersetID==groupID}
        let survivor=groupBeforeRemove[1],removed=groupBeforeRemove[0]
        afterDetach.removeExercise(removed.id)
        check(afterDetach.data.draft!.exercises.first{$0.id==survivor.id}!.supersetID==nil && afterDetach.data.draft!.exercises.first{$0.id==survivor.id}!.sets==survivor.sets,"removing one of two group members dissolves orphan without changing surviving sets")
        check(AppStore(storageURL:afterDetach.storageURL).data.draft!.exercises==afterDetach.data.draft!.exercises,"orphan cleanup after exercise removal persists")
        let newPickerMatches=Catalog.all.filter{ExerciseLibraryFilter(query:"tay cam vai day",muscle:"Vai",levels:[1],gears:["Dây"],ownedGear:["Dây kháng lực"]).matches($0)}
        check(newPickerMatches.map(\.id)==["bandpress"],"new picker combines accent-free reordered words muscle difficulty gear and owned equipment")
        check(!ExerciseLibraryFilter(query:"vai day",muscle:"Ngực").matches(Catalog.alternatives[0]),"contradictory picker filters produce empty results")
        check(ExerciseLibraryFilter(levels:[1,3]).matches(Catalog.alternatives[0]) && ExerciseLibraryFilter(levels:[1,3]).matches(Catalog.lower[0]),"multiple difficulty filters use union within category")
        check(!ExerciseLibraryFilter(todayMuscles:["Ngực"]).matches(Catalog.lower[1]) && ExerciseLibraryFilter(todayMuscles:["Đùi trước"]).matches(Catalog.lower[1]),"today filter uses selected primary muscles")
        let pickerSnapshot=try JSONEncoder().encode(updated.data)
        for ex in Catalog.all {_ = ExerciseLibraryFilter(query:"ta").matches(ex)}
        check((try JSONSerialization.jsonObject(with:JSONEncoder().encode(updated.data)) as? NSDictionary)==(try JSONSerialization.jsonObject(with:pickerSnapshot) as? NSDictionary),"browsing and filtering never mutates workout data")
        var challengeCalendar=Calendar(identifier:.gregorian);challengeCalendar.timeZone=TimeZone(secondsFromGMT:0)!;challengeCalendar.firstWeekday=2
        let challengeStart=ISO8601DateFormatter().date(from:"2026-11-09T08:00:00Z")!
        let challengeStore=AppStore(storageURL:dir.appendingPathComponent("challenge-state.json"))
        let originalDraft=challengeStore.data.draft!.id
        check(challengeStore.data.challenges==nil,"old state loads without challenge field")
        check(challengeStore.joinChallenge("consistent-14",on:challengeStart) && !challengeStore.joinChallenge("consistent-14",on:challengeStart),"challenge enrollment persists and rejects duplicate active joins")
        check(challengeStore.data.draft?.id==originalDraft && challengeStore.data.history.isEmpty,"joining a challenge does not replace draft or create workouts")
        check(AppStore(storageURL:challengeStore.storageURL).data.challenges?.count==1,"challenge enrollment survives reload")
        let definition=WorkoutChallenge.all[0],enrollment=challengeStore.activeEnrollment(definition.id,on:challengeStart)!
        var dayA=WorkoutSession(name:"Test",exercises:[WorkoutExercise(Catalog.upper[1])]);dayA.exercises[0].sets[0].completed=true;dayA.started=challengeStart.addingTimeInterval(3600)
        var dayB=dayA;dayB.id=UUID();dayB.started=dayA.started.addingTimeInterval(3600)
        var dayC=dayA;dayC.id=UUID();dayC.started=challengeStart.addingTimeInterval(86400)
        var beforeJoin=dayA;beforeJoin.started=challengeStart.addingTimeInterval(-1)
        var afterEnd=dayA;afterEnd.started=challengeCalendar.date(byAdding:.day,value:14,to:challengeCalendar.startOfDay(for:challengeStart))!
        let history=[dayA,dayB,dayC,beforeJoin,afterEnd]
        check(WorkoutCalendarLogic.progress(definition,enrollment:enrollment,history:history,now:afterEnd.started,calendar:challengeCalendar).count==2,"challenge counts unique training days and excludes earlier or expired workouts")
        check(WorkoutCalendarLogic.progress(WorkoutChallenge.all[2],enrollment:enrollment,history:history,now:afterEnd.started,calendar:challengeCalendar).isEmpty,"lower-body challenge does not count upper-body workouts")
        let calendarWeek=WorkoutCalendarLogic.week(containing:challengeStart,calendar:challengeCalendar)
        check(calendarWeek.count==7 && challengeCalendar.component(.weekday,from:calendarWeek[0])==2,"workout calendar has seven local days beginning Monday")
        check(WorkoutCalendarLogic.trainingDays([dayA,dayB,dayC],in:calendarWeek,calendar:challengeCalendar).count==2,"weekly goal counts days rather than duplicate sessions")
        check(challengeStore.leaveChallenge(definition.id,on:dayC.started) && challengeStore.activeEnrollment(definition.id,on:dayC.started)==nil && challengeStore.data.draft?.id==originalDraft,"leaving challenge preserves draft and closes enrollment")
        check(!challengeStore.joinChallenge("unknown",on:challengeStart),"unknown challenges cannot be enrolled")

        let programs=WorkoutProgramGroup.all.flatMap{g in (1...3).map{WorkoutProgram(group:g,level:$0)}}
        check(programs.count==21 && Set(programs.map(\.id)).count==21,"seven muscle groups expose three unique program levels")
        check(programs.allSatisfy{!$0.exercises.isEmpty && $0.exercises.allSatisfy{!$0.sets.isEmpty}},"every program resolves actual exercises and prescriptions")
        check(WorkoutProgramGroup.all.allSatisfy{WorkoutProgram(group:$0,level:1).minutes<WorkoutProgram(group:$0,level:3).minutes},"program duration increases from actual prescribed work at higher levels")
        check(programs.allSatisfy{$0.exercises.allSatisfy{$0.doneCount==0}},"program previews never contain prelogged sets")
        check(WorkoutChallenge.all.count==12 && Set(WorkoutChallenge.all.map(\.id)).count==12,"all twelve challenge definitions have stable unique identities")
        let programStore=AppStore(storageURL:dir.appendingPathComponent("program-state.json"))
        programStore.data.history=[dayA]
        let priorExercises=programStore.data.draft!.exercises,priorHistory=programStore.data.history
        let absProgram=programs[0]
        check(programStore.applyProgram(absProgram) && Array(programStore.data.draft!.exercises.prefix(priorExercises.count))==priorExercises && programStore.data.history==priorHistory,"adding program preserves all existing prescriptions and history")
        check(AppStore(storageURL:programStore.storageURL).data.draft!.exercises.count==priorExercises.count+absProgram.exercises.count,"added custom program exercises survive reload")
        programStore.data.draft!.hasStarted=true
        let activeSnapshot=programStore.data.draft!
        check(!programStore.applyProgram(programs[1],replacing:true) && programStore.data.draft==activeSnapshot,"replacing an active draft is blocked without losing data")
        programStore.data.draft!.hasStarted=false;programStore.data.draft!.exercises[0].sets[0].completed=true
        check(!programStore.applyProgram(programs[1],replacing:true),"replacing draft with logged sets is blocked even before start flag")
        programStore.data.draft!.exercises[0].sets[0].completed=false
        check(programStore.applyProgram(programs[1],replacing:true) && programStore.data.draft!.name==programs[1].title && programStore.data.history==priorHistory,"explicit replacement of unstarted draft creates selected prescription and preserves history")
        let manualStore=AppStore(storageURL:dir.appendingPathComponent("practice-state.json"))
        check(manualStore.data.challengePractices==nil && !manualStore.recordPractice("pelvic-14",on:challengeStart),"old snapshots load and unjoined practice cannot be logged")
        check(manualStore.joinChallenge("pelvic-14",on:challengeStart) && manualStore.recordPractice("pelvic-14",on:dayA.started),"joined manual practice records a real explicit checkin")
        check(!manualStore.recordPractice("pelvic-14",on:dayB.started) && !manualStore.recordPractice("upper-28",on:dayA.started),"manual practice deduplicates local days and rejects workout-only challenges")
        let pelvic=WorkoutChallenge.all.first{$0.id=="pelvic-14"}!,pelvicEnrollment=manualStore.activeEnrollment("pelvic-14",on:dayA.started)!
        let manualProgress=WorkoutCalendarLogic.progress(pelvic,enrollment:pelvicEnrollment,history:history,now:dayC.started,calendar:challengeCalendar,practices:manualStore.data.challengePractices ?? [])
        check(manualProgress.count==1 && manualStore.data.history.isEmpty,"manual practice uses checkins rather than unrelated workouts and never creates workout history")
        check(AppStore(storageURL:manualStore.storageURL).data.challengePractices?.count==1,"manual checkins survive reload")
        check(manualStore.recordPractice("pelvic-14",on:dayA.started,remove:true) && manualStore.data.challengePractices?.isEmpty==true,"today practice checkin can be undone")
        let calis=WorkoutChallenge.all.first{$0.id=="calisthenics-28"}!,dbChallenge=WorkoutChallenge.all.first{$0.id=="dumbbell-30"}!
        check(!calis.accepts(Catalog.upper[1]) && calis.accepts(WorkoutProgramCatalog.exercises[0]),"calisthenics counts bodyweight work, not loaded barbell workouts")
        check(!dbChallenge.accepts(Catalog.upper[1]) && dbChallenge.accepts(Catalog.beginnerUpper[0]),"dumbbell challenge requires actual dumbbell equipment")

        let timedStore=AppStore(storageURL:dir.appendingPathComponent("timed-program-state.json"))
        _ = timedStore.applyProgram(programs[0],replacing:true)
        let plankRow=timedStore.data.draft!.exercises.first{$0.exercise.timed}!
        let plankSet=plankRow.sets[0].id
        timedStore.mutateExercise(plankRow.id){$0.sets[0].seconds=0}
        timedStore.logSet(exercise:plankRow.id,set:plankSet)
        check(timedStore.data.draft!.completedSets==0,"zero-duration timed set cannot be logged")
        timedStore.mutateExercise(plankRow.id){$0.sets[0].seconds=30}
        timedStore.logSet(exercise:plankRow.id,set:plankSet)
        check(timedStore.data.draft!.completedSets==1 && timedStore.data.draft!.volume==0,"timed seconds log without inventing repetition volume")
        let timedSaved=timedStore.finish()!
        var timedItem=timedSaved.exercises[0];timedItem.sets[0].seconds=40
        check(timedStore.saveHistoryExercise(sessionID:timedSaved.id,item:timedItem) && AppStore(storageURL:timedStore.storageURL).data.history[0].exercises[0].sets[0].seconds==40,"timed set editing and duration survive finish/save/reload")
        check(timedStore.csvData().contains("duration_seconds") && timedStore.csvData().contains(",40"),"CSV preserves actual timed duration")
        let checkinStore=AppStore(storageURL:dir.appendingPathComponent("checkin-state.json"))
        let checkinBase=checkinStore.data.draft!.exercises
        func workingSets(_ item:WorkoutExercise)->Int {item.sets.filter{!$0.warmup}.count}
        check(checkinStore.applyCheckin(.tired),"tired check-in applies to an untouched workout")
        check(zip(checkinBase,checkinStore.data.draft!.exercises).allSatisfy{pair in workingSets(pair.1)==(workingSets(pair.0)>2 ? workingSets(pair.0)-1:workingSets(pair.0)) && (pair.1.sets.first{!$0.warmup}?.weight ?? 0)<=(pair.0.sets.first{!$0.warmup}?.weight ?? 0)},"tired check-in drops one set and never raises a load")
        check(checkinStore.applyCheckin(.good) && checkinStore.data.draft!.exercises==checkinBase,"choosing good restores the original workout")
        check(checkinStore.applyCheckin(.pain,pain:["Vai"]) && !checkinStore.data.draft!.exercises.contains{JointLoad.joints($0.exercise).contains("Vai")},"pain check-in swaps or removes exercises loading the painful joint")
        check(checkinStore.data.history.isEmpty && AppStore(storageURL:checkinStore.storageURL).data.checkin?.painAreas==["Vai"],"check-in persists without creating history")
        do {
            let soft=AppStore(storageURL:FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString+".json"))
            soft.changePlan{$0.gentle=true};soft.makeDraft(lower:true)
            let items=soft.data.draft!.exercises
            check(items.count<=5 && items.allSatisfy{$0.sets.filter{!$0.warmup}.count<=2} && !items.contains{["Tạ đòn","Trap Bar","T-Bar Row"].contains($0.exercise.equipment)},"gentle mode builds a short, lighter workout without barbells")
        }
        do {
            var probe=WorkoutExercise(Catalog.upper[0]);probe.sets=[LoggedSet(reps:8,weight:20),LoggedSet(reps:8,weight:50)]
            let r=CheckinLogic.ramped(probe,peak:40,factor:0.85,profile:GymProfile(name:"Test"))
            check(r.sets[0].weight>=30 && r.sets[0].weight<=40 && r.sets[1].weight==40,"return ramp lifts low sets toward the old level but never above it")
        }
        do {
            let expiring=AppStore(storageURL:FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString+".json"))
            expiring.makeDraft(lower:false)
            let before=expiring.data.draft!.exercises.map(\.exercise.id),beforeSets=expiring.data.draft!.exercises.map(\.sets.count)
            _ = expiring.applyCheckin(.tired)
            expiring.expireCheckinIfNeeded(now:Date().addingTimeInterval(86400*2))
            check(expiring.data.checkin==nil && expiring.data.draft!.exercises.map(\.exercise.id)==before && expiring.data.draft!.exercises.map(\.sets.count)==beforeSets,"yesterday's check-in is undone on a new day")
        }
        check(checkinStore.data.draft!.exercises.contains{checkinStore.checkinChanged($0)} && !(checkinStore.todayCheckin?.notes.isEmpty ?? true),"pain check-in visibly changes the workout")
        check(checkinStore.data.draft!.exercises.filter{JointLoad.touches($0.exercise,"Vai")}.allSatisfy{checkinStore.checkinChanged($0)},"every exercise still using the painful area is swapped or lightened")
        check(checkinStore.applyCheckin(.short,minutes:15) && checkinStore.data.draft!.exercises.count==2 && checkinStore.data.draft!.plannedMinutes==15,"short check-in trims the workout to the chosen time")
        checkinStore.clearCheckin()
        check(checkinStore.data.draft!.exercises==checkinBase && checkinStore.data.checkin==nil,"undo restores the original workout")
        checkinStore.data.draft!.hasStarted=true
        check(!checkinStore.applyCheckin(.tired) && checkinStore.data.draft!.exercises==checkinBase,"a started workout is never changed by check-in")
        let breakStore=AppStore(storageURL:dir.appendingPathComponent("break-state.json"))
        breakStore.changePlan{$0.experience="Mới bắt đầu";$0.split="Thân trên / Thân dưới";$0.warmup=false;$0.minutes=60}
        breakStore.makeDraft(lower:false)
        var breakOld=breakStore.data.draft!
        breakOld.id=UUID()
        for i in breakOld.exercises.indices {for j in breakOld.exercises[i].sets.indices {breakOld.exercises[i].sets[j].completed=true}}
        breakOld.started=Calendar.current.date(byAdding:.day,value:-20,to:Date())!
        breakStore.data.history=[breakOld]
        breakStore.makeDraft(lower:false)
        check(breakStore.data.draft!.returnBreakDays==20,"a twenty-day gap is detected when building the next workout")
        let easedRow=breakStore.data.draft!.exercises.first{$0.exercise.id=="dumbbell-row"}!,oldRow=breakOld.exercises.first{$0.exercise.id=="dumbbell-row"}!
        check(easedRow.sets[0].weight<oldRow.sets[0].weight,"returning after a long break lowers the load instead of progressing")
        check(breakStore.todayReason()?.contains("nghỉ 20 ngày")==true,"home explains the lighter return workout")
        breakStore.data.history[0].started=Calendar.current.date(byAdding:.day,value:-3,to:Date())!
        breakStore.makeDraft(lower:false)
        check(breakStore.data.draft!.returnBreakDays==nil,"a short gap does not ease the workout")
        print("\(passed) model checks passed.")
    }
}
