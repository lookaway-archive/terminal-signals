==============================================================
  T7 PLATE TRACER
  scene: /job/sharp/103/103_sc011/103_sc011_0120/work/snino/maya/scenes/103_sc011_0120_test_cam_FROM_130.mb
==============================================================
  timeline: 1001 - 1077   (77 frames)

-- CAMERAS / RIG DEPTH --
  Camera01_:camera_:rig_:render_:cameraLeftShape
    transform: Camera01_:camera_:rig_:render_:cameraLeft   |   rig depth: 10 parent levels
    driven by: addDoubleLinear x4, choice x22, objectSet x1, parentConstraint x1, plusMinusAverage x1, reverse x1, transform x2
  Camera01_:camera_:rig_:render_:cameraRightShape
    transform: Camera01_:camera_:rig_:render_:cameraRight   |   rig depth: 10 parent levels
    driven by: addDoubleLinear x4, choice x22, objectSet x1, parentConstraint x1, plusMinusAverage x1, reverse x1, transform x3
  Camera01_:camera_:rig_:render_:cameraShape
    transform: Camera01_:camera_:rig_:render_:camera   |   rig depth: 11 parent levels
    driven by: parentConstraint x1, stereoRigTransform x1, transform x2
  Camera01_:camera_:rig_:tracking_:cameraShape
    transform: Camera01_:camera_:rig_:tracking_:camera   |   rig depth: 10 parent levels
    driven by: addDoubleLinear x2, objectSet x1, plManimConnectNode x1, reverse x1, transform x1, unitConversion x1
  Manticore01_:geo_:rig_:face_:C_faceCameraA_CTLShape
    transform: Manticore01_:geo_:rig_:face_:C_faceCameraA_CTL   |   rig depth: 15 parent levels
  Manticore01_:geo_:rig_:face_:C_faceCameraB_CTLShape
    transform: Manticore01_:geo_:rig_:face_:C_faceCameraB_CTL   |   rig depth: 15 parent levels
  Manticore01_:geo_:rig_:face_:C_faceCameraC_CTLShape
    transform: Manticore01_:geo_:rig_:face_:C_faceCameraC_CTL   |   rig depth: 15 parent levels

--- IMAGE PLANES (the plate) --

  [Camera01_:camera_:rig_:render_:cameraLeftShape->Camera01_:camera_:rig_:render_:cameraLeft_animationMaskShape]  ->  camera: Camera01_:camera_:rig_:render_:cameraLeft
      imageName            :    <== THE INPUT
      type                 : 0
      useFrameExtension    : False
      frameExtension       : 1016
      frameOffset          : 0
      frameCache           : 35   <== CACHE LEVER
      displayMode          : 3
      fit                  : 2
      depth                : 0.1
      displayOnlyIfCurrent : True
      input chain (what drives the plate):
        .frameExtension     <- Camera01_:camera_:rig_:condition2.outColorR
      upstream nodes: colorManagementGlobals x1, condition x2, transform x1

  [Camera01_:camera_:rig_:render_:cameraRightShape->Camera01_:camera_:rig_:render_:cameraRight_animationMaskShape]  ->  camera: Camera01_:camera_:rig_:render_:cameraRight
      imageName            :    <== THE INPUT
      type                 : 0
      useFrameExtension    : False
      frameExtension       : 1016
      frameOffset          : 0
      frameCache           : 35   <== CACHE LEVER
      displayMode          : 3
      fit                  : 2
      depth                : 0.1
      displayOnlyIfCurrent : True
      input chain (what drives the plate):
        .frameExtension     <- Camera01_:camera_:rig_:condition12.outColorR
      upstream nodes: colorManagementGlobals x1, condition x2, transform x1

[Camera01_:camera_:rig_:tracking_:cameraShape->Camera01_:camera_:rig_:tracking_:camera_backgroundShape]  ->  camera: Camera01_:camera_:rig_:tracking_:camera
      imageName            : /job/sharp/vault/vfx_image_sequence/103/103_sc011/103_sc011_0130/3_V11P_C_1/asset_backplate/bg01_tracking_fullres_mtl.sharp.asset.5044501/v001/103_sc011_0130_backplate_bg01_v001_main.#.exr   <== THE INPUT   [NFS network read]
      type                 : 1
      useFrameExtension    : True
      frameExtension       : 1016
      frameOffset          : 0
      frameCache           : 35   <== CACHE LEVER
      displayMode          : 3
      fit                  : 4
      depth                : 100.0
      displayOnlyIfCurrent : True
      input chain (what drives the plate):
        .frameExtension     <- Camera01_:camera_:rig_:condition1.outColorR
      upstream nodes: colorManagementGlobals x1, condition x1, transform x1

  [imagePlaneShape1]  ->  camera: persp
      imageName            : /job/sharp/103/103_sc011/103_sc011_0120/work/snino/maya/images/sourceimages/edit_ref_v1001/edit.1001.jpeg   <== THE INPUT   [NFS network read]
      type                 : 0
      useFrameExtension    : True
      frameExtension       : 1016
      frameOffset          : 0
      frameCache           : 100   <== CACHE LEVER
      displayMode          : 3
      fit                  : 1
      depth                : 100.0
      displayOnlyIfCurrent : False
      input chain (what drives the plate):
        .frameExtension     <- timeToUnitConversion2.output
      upstream nodes: colorManagementGlobals x1, timeToUnitConversion x1, transform x1

  [imagePlaneShape2]  ->  camera: Camera01_:camera_:rig_:render_:cameraLeft
      imageName            : /job/sharp/103/103_sc011/103_sc011_0120/work/snino/maya/images/sourceimages/eating_ref_v1002/eating.v1002.1001.jpeg   <== THE INPUT   [NFS network read]
      type                 : 0
      useFrameExtension    : True
      frameExtension       : 1016
      frameOffset          : 50
      frameCache     

-- SCENE FOOTPRINT --
  expressions: 0   scriptNodes: 7   total nodes: 31810

-- THE LEVER --
  Camera01_:camera_:rig_:render_:cameraLeftShape->Camera01_:camera_:rig_:render_:cameraLeft_animationMaskShape
    plate: 
    frameCache = 35  (caching already active)
  Camera01_:camera_:rig_:render_:cameraRightShape->Camera01_:camera_:rig_:render_:cameraRight_animationMaskShape
    plate: 
    frameCache = 35  (caching already active)
  Camera01_:camera_:rig_:tracking_:cameraShape->Camera01_:camera_:rig_:tracking_:camera_backgroundShape
    plate: /job/sharp/vault/vfx_image_sequence/103/103_sc011/103_sc011_0130/3_V11P_C_1/asset_backplate/bg01_tracking_fullres_mtl.sharp.asset.5044501/v001/103_sc011_0130_backplate_bg01_v001_main.#.exr
    frameCache = 35  (caching already active)
    plate is on a network share -> first scrub reads NFS;
    RAM caching is what makes repeat scrubs smooth.
  imagePlaneShape1
    plate: /job/sharp/103/103_sc011/103_sc011_0120/work/snino/maya/images/sourceimages/edit_ref_v1001/edit.1001.jpeg
    frameCache = 100  (caching already active)
    plate is on a network share -> first scrub reads NFS;
    RAM caching is what makes repeat scrubs smooth.
  imagePlaneShape2
    plate: /job/sharp/103/103_sc011/103_sc011_0120/work/snino/maya/images/sourceimages/eating_ref_v1002/eating.v1002.1001.jpeg
    frameCache = 100  (caching already active)
    plate is on a network share -> first scrub reads NFS;
    RAM caching is what makes repeat scrubs smooth.
==============================================================


