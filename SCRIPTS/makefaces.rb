# Copyright 2004-2006, Todd Burch - Burchwood USA   http://www.burchwoodusa.com 

=begin
Smustard.com(tm) Ruby Script End User License Agreement

This is a License Agreement is between you and Smustard.com.

If you download, acquire or purchase a Ruby Script or any freeware or any other product (collectively "Scripts") from Smustard.com, then you hereby accept and agree to all of the following terms and conditions:

Smustard.com, through its agreements with individual script authors, hereby grants you a permanent, worldwide, non-exclusive, non-transferable, non-sublicensable use license with respect to its rights in the Scripts.

If you are an individual, then you may copy the Scripts onto any computer you own at any location.

If you are an entity, then you may not copy the Scripts onto any other computer unless you purchase a separate license for each computer and you must have a separate license for the use of the Script on each computer.

You may not alter, publish, market, distribute, give, transfer, sell or sublicense the Scripts or any part of the Scripts.

This License Agreement is governed by the laws of the State of Texas and the United States of America.

You agree to submit to the jurisdiction of the Courts in Houston, Harris County, Texas, United States of America, to resolve any dispute, of any kind whatsoever, arising out of, involving or relating to this License Agreement.

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

This software has not been endorsed or sanctioned by Google.  Any comments, concerns or issues about this software 
or the affects of this software should be not directed to Google, but to Smustard.com.  
=end

# Name :          makefaces.rb 1.4
# Description :   Creates faces only on selected objects that could potentially receive a face.
# Author :        Todd Burch   http://www.burchwoodusa.com 
# Usage :         1. select all elements for which you want a face.
#                 2. Run "Make Faces" from the Tools menu.
# Date :          17.Jul.2004
# Type :          Tool
# History:        1.0 (17.Jul.2004) - first version
#                 1.1 (23.Aug.2004) - Add text-based percentage complete progress messages
#                                   - Move statistics to a pop-up messagebox from the Ruby Console.
#                 1.2 (27.Apr.2006) - upgrade to new progressbar.rb                  
#                 1.3 (12.May.2006) - upgrade to new require error handling code 
#                 1.4 (14.May.2006) - change algorithm for obtaining the user's selection 
#-----------------------------------------------------------------------------


required_mods = %w(sketchup.rb progressbar.rb) 

error_mods = Array.new 
syntax_mods = Array.new 

required_mods.each {|m| 
  begin 
    require m ; 
  rescue LoadError => error_text
    error_mods << m << "\n" << error_text << "\n" ; 
  rescue SyntaxError => error_text
    syntax_mods << m << "\n" << error_text << "\n" ; 
    end 
  }

if !error_mods.empty? || !syntax_mods.empty? then 

  txt_err = 
  "The files listed below could not be loaded:
-------------------------------------------\n"
  txt_syn = 
"The files listed below have syntax errors:  
-------------------------------------------\n"  
  dev = "Contact the developer of this script at this address:

      toddb@smustard.com

for how/where to obtain any required files and/or a fix.
We are sorry for this inconvenience."

  error_mods.unshift(txt_err) if !error_mods.empty? 
  syntax_mods.unshift(txt_syn) if !syntax_mods.empty? 
  UI.messagebox("#{__FILE__}\n\n#{error_mods}\n\n#{syntax_mods}\n\n#{dev}")
  exit ;
  end 

#-----------------------------------------------------------------------------
#
#  The following method will format the elapsed time when passed the total seconds
#  elapsed for a process.    
#
#  To use the routine, at the start of your script, issue: t1 = Time.now
#  That is the start time.
#
#  When your script is about finished, call this method while issueing 
#  the Time.now method again, and subtracting the initial time like this: 
#  elapsed_time = seconds_2_dhms(Time.now-t1).  
#
#  A formatted string is returned, in the format: 
# 
#  "W Days, X Hour(s), Y Minute(s), and Z Seconds."
#
#  If only seconds had elapsed (a quick running process), then only "Z Seconds." will be 
#  returned.  If the process lasted over a minute, "Y Minute(s), Z Seconds." will be returned, 
#  and so on. 
#
#
#-----------------------------------------------------------------------------

def seconds_2_dhms (secs)   # Input is seconds:  Time2 - Time1
    seconds = secs % 60     # Calcuate whole and fractional seconds.
    time = secs.round       # Round to nearest whole second.
    time /= 60              # Divide by 60 to remove seconds.
    minutes = time % 60     # Calculate portions of a hour.
    time /= 60              # Remove any portions of an hour 
    hours = time % 24       # Calculate portions of a day in hours
    days = time / 24        # The remainder is days

    if (days > 0) then days = days.to_s<<" Day(s), "  else days = " " end 
    if (hours > 0) then hours = hours.to_s<<" Hour(s), " else hours = " " end 
    if (minutes > 0) then minutes = minutes.to_s<< " Minute(s), " else minutes = " " end  
    seconds = seconds.to_s<< " Second(s)." 
    return (days<<hours<<minutes<<seconds).strip!
    end   # seconds_2_dhms 


#-----------------------------------------------------------------------------
#
# This routine creates faces from lines that make up closed sections.
#
#-----------------------------------------------------------------------------

def makeFaces14
    t1 = Time.now 
    am = Sketchup.active_model        # Sketchup Active Model. 
    am.start_operation "Make Faces"
    #Get the current selection 
    se = am.active_entities           # Sketchup Active Entities.  Allows working inside a component.
    ss = am.selection                 # Work with selection, if any... 
    if ss.length == 0 then ss = se end     # ...else work with whole model. 
    total_items = ss.count      # Total count of all selected entities.
    x = 0                       # faces-added accumulator 
    z = 0                       # loop count
    pb = ProgressBar.new(total_items,"Making Faces...") ; 
    notAnEdge = 0               # Accumulator for non-Edges 
    ss.each {|e|
      if e.typename == "Edge" then  # find_faces only works on edges.
         x += e.find_faces          # This creates faces if they can created. Returns # faces created.
      else notAnEdge+=1             # Keep track of selections that were not an edge.
         end
      z+=1                          # bump loop counter      
      pb.update(z) ;                # Report Progress
      }   
    am.commit_operation    # "Make Faces"

    # Calculate the time that has elapsed in seconds. 
    elap = seconds_2_dhms(Time.now - t1) 
    UI.messagebox("makefaces.rb: Copyright 2004-2006 Burchwood USA."        <<
                  "\nVersion 1.2   May 14,2006."                    << 
                  "\n\nThere were " << total_items.to_s << " selected items."   <<
                  "\n\nThere were " << notAnEdge.to_s << " non-Edge selected items."   <<
                  "\nThere were " << (total_items-notAnEdge).to_s << " Edges selected."   <<
                  "\n\nThere were " << x.to_s << " face(s) added."       <<  
                  "\nThe process lasted: "<< elap, MB_MULTILINE, "Make Faces Statistics")
    end  # makeFaces14
   
# This will add an item called "Make Faces 1.4" to the Tools menu.

UI.menu("Tools").add_item("Make Faces 1.4") { makeFaces14 } if not file_loaded?("makefaces.rb") 
file_loaded("makefaces.rb")
