# ===========================================================================================================================================================
# SimLab STL Importer 
# Copyright 2019 SimLab Soft. All rights reserved
# 
# www.simlab-soft.com
# ===========================================================================================================================================================

require 'sketchup.rb'
require 'extensions.rb'
  
ext = SketchupExtension.new 'SimLab STL Importer', 'SimLabSTLImporter/SimLabSTLImporter_loader.rb'

ext.creator     = 'SimLab Soft'
ext.version     = '9.0.0'
ext.copyright   = '2019 SimLab Soft. All rights reserved.'
ext.description = 'SimLab STL Importer! Visit www.simlab-soft.com for support.'

Sketchup.register_extension ext, true
