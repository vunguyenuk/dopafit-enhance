from pathlib import Path
import hashlib
def uid(s):return hashlib.sha1(s.encode()).hexdigest()[:24].upper()
files=sorted(Path('DopafitRebuild').glob('*.swift'))
resources=['Assets.xcassets','OpenGym3D','Form3D','ExerciseMedia']
objects={}
def add(key,body):objects[uid(key)]=body;return uid(key)
refs=[]
builds=[]
resbuild=[]
for f in files:
    ref=add('ref:'+f.name,'{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "'+f.name+'"; sourceTree = "<group>"; }')
    refs.append(ref)
    builds.append(add('build:'+f.name,'{isa = PBXBuildFile; fileRef = '+ref+'; }'))
for name in resources:
    ref=add('ref:'+name,'{isa = PBXFileReference; lastKnownFileType = '+('folder.assetcatalog' if name.endswith('.xcassets') else 'folder')+'; path = "'+name+'"; sourceTree = "<group>"; }')
    refs.append(ref);resbuild.append(add('build:'+name,'{isa = PBXBuildFile; fileRef = '+ref+'; }'))
product=add('product','{isa = PBXFileReference; explicitFileType = wrapper.application; path = Dopafit.app; sourceTree = BUILT_PRODUCTS_DIR; }')
src=add('src','{isa = PBXGroup; children = ('+','.join(refs)+'); path = DopafitRebuild; sourceTree = "<group>"; }')
prod=add('products','{isa = PBXGroup; children = ('+product+'); name = Products; sourceTree = "<group>"; }')
main=add('main','{isa = PBXGroup; children = ('+src+','+prod+'); sourceTree = "<group>"; }')
sourcephase=add('sources','{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ('+','.join(builds)+'); runOnlyForDeploymentPostprocessing = 0; }')
resourcephase=add('resources','{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ('+','.join(resbuild)+'); runOnlyForDeploymentPostprocessing = 0; }')
frameworkphase=add('frameworks','{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }')
def configs(prefix,settings):
    cs=[]
    for mode in ['Debug','Release']:
        vals=dict(settings)
        vals['SWIFT_OPTIMIZATION_LEVEL']='"-Onone"' if mode=='Debug' else '"-O"'
        cs.append(add(prefix+mode,'{isa = XCBuildConfiguration; buildSettings = {'+' '.join(k+' = '+v+';' for k,v in vals.items())+'}; name = '+mode+'; }'))
    return add(prefix+'list','{isa = XCConfigurationList; buildConfigurations = ('+','.join(cs)+'); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }')
projectconfig=configs('projectcfg',{'SDKROOT':'iphoneos','IPHONEOS_DEPLOYMENT_TARGET':'17.0','CLANG_ENABLE_MODULES':'YES','SWIFT_VERSION':'5.0','ENABLE_USER_SCRIPT_SANDBOXING':'YES'})
targetconfig=configs('targetcfg',{'PRODUCT_BUNDLE_IDENTIFIER':'com.local.dopafit.rebuild','PRODUCT_NAME':'Dopafit','INFOPLIST_FILE':'DopafitRebuild/Info.plist','GENERATE_INFOPLIST_FILE':'NO','TARGETED_DEVICE_FAMILY':'1','CODE_SIGN_STYLE':'Automatic','SWIFT_VERSION':'5.0','IPHONEOS_DEPLOYMENT_TARGET':'17.0','ENABLE_PREVIEWS':'YES'})
target=add('target','{isa = PBXNativeTarget; buildConfigurationList = '+targetconfig+'; buildPhases = ('+sourcephase+','+frameworkphase+','+resourcephase+'); buildRules = (); dependencies = (); name = Dopafit; productName = Dopafit; productReference = '+product+'; productType = "com.apple.product-type.application"; }')
project=add('project','{isa = PBXProject; attributes = {LastUpgradeCheck = 2700;}; buildConfigurationList = '+projectconfig+'; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; knownRegions = (en,vi,Base); mainGroup = '+main+'; productRefGroup = '+prod+'; projectDirPath = ""; projectRoot = ""; targets = ('+target+'); }')
path=Path('Dopafit.xcodeproj');path.mkdir(exist_ok=True)
(path/'project.pbxproj').write_text('// !$*UTF8*$!\n{archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n'+'\n'.join(k+' = '+v+';' for k,v in objects.items())+'\n}; rootObject = '+project+';}\n')
scheme=path/'xcshareddata/xcschemes';scheme.mkdir(parents=True,exist_ok=True)
buildref='<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="'+target+'" BuildableName="Dopafit.app" BlueprintName="Dopafit" ReferencedContainer="container:Dopafit.xcodeproj"/>'
(scheme/'Dopafit.xcscheme').write_text('<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="2700" version="1.3"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">'+buildref+'</BuildActionEntry></BuildActionEntries></BuildAction><LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">'+buildref+'</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release"><BuildableProductRunnable runnableDebuggingMode="0">'+buildref+'</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>')
print(path.resolve())
