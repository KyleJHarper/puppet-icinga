#!/usr/bin/ruby

# A simple nagios check that should be run as root
# perhaps under the mcollective NRPE plugin and
# can check when the last run was done of puppet.
# It can also check fail counts and skip machines
# that are not enabled
#
# The script will use the puppet last_run-summar.yaml
# file to determine when last Puppet ran else the age
# of the statefile.

require 'optparse'
require 'yaml'

lockfile = "/var/lib/puppet/state/puppetdlock"
statefile = "/var/lib/puppet/state/state.yaml"
summaryfile = "/var/lib/puppet/state/last_run_summary.yaml"
agentpidfile = "/var/run/puppet/agent.pid"
enabled = true
running = false
lastrun_failed = false
lastrun = 0
failcount = 0
warn = 0
crit = 0
enabled_only = false
failures = false

opt = OptionParser.new

opt.on("--critical [CRIT]", "-c", Integer, "Critical threshold, time or failed resources") do |f|
    crit = f.to_i
end

opt.on("--warn [WARN]", "-w", Integer, "Warning thresold, time of failed resources") do |f|
    warn = f.to_i
end

opt.on("--check-failures", "-f", "Check for failed resources instead of time since run") do |f|
    failures = true
end

opt.on("--only-enabled", "-e", "Only alert if Puppet is enabled") do |f|
    enabled_only = true
end

opt.on("--lock-file [FILE]", "-l", "Location of the lock file, default #{lockfile}") do |f|
    lockfile = f
end

opt.on("--state-file [FILE]", "-t", "Location of the state file, default #{statefile}") do |f|
    statefile = f
end

opt.on("--summary-file [FILE]", "-s", "Location of the summary file, default #{summaryfile}") do |f|
    summaryfile = f
end

opt.parse!

if warn == 0 || crit == 0
    puts "Please specify a warning and critical level"
    exit 3
end

# With options parsed, check to make sure puppet is *actually* running like it ALWAYS should be... duh?
if !File.exists?(agentpidfile)
    puts "Cannot find the agent pid file.  Puppet likely isn't running."
    exit 2
end
if ! system("/usr/sbin/service puppet status >/dev/null")
    puts "The puppet service isn't running."
    exit 2
end

# This block isn't actually checking the puppet agent service or its pid.  This whole script doesn't even care.
# Therefore, I'm adding the block directly above this to check for it and abort early if puppet isn't running.
if File.exists?(lockfile)
    if File::Stat.new(lockfile).zero?
       enabled = false
    else
       running = true
    end
end

lastrun = File.stat(statefile).mtime.to_i if File.exists?(statefile)

if File.exists?(summaryfile)
    begin
        summary = YAML.load_file(summaryfile)
        lastrun = summary["time"]["last_run"]

        # machines that outright failed to run like on missing dependencies
        # are treated as huge failures.  The yaml file will be valid but
        # it wont have anything but last_run in it
        unless summary.include?("events")
            failcount = 99
        else
            # and unless there are failures, the events hash just wont have the failure count
            failcount = summary["events"]["failure"] || 0
        end
    rescue
        failcount = 0
        summary = nil
    end
end

time_since_last_run = Time.now.to_i - lastrun

# 2014.05.28 : Rewriting this block to support perfdata in all cases.  And because the original block is horrid.
perfdata = ""
time_rv = 0
failures_rv = 0
msg = "Puppet running."
# -- Check on time
if time_since_last_run < warn
  msg << "  Last run completed #{time_since_last_run} seconds ago."
end
if time_since_last_run >= warn
  msg << "  Puppet hasn't ran in a long time (#{time_since_last_run} seconds ago), might be dead."
  time_rv = 1
end
if time_since_last_run >= crit
  time_rv = 2
end
perfdata << " last_run=#{time_since_last_run};#{warn};#{crit};; "
# -- Check on failures.  Only 0 is acceptable.
if failcount == 0
  msg << "  No failures."
end
if failcount > 0
  msg << "  Encountered #{failcount} failures."
  failures_rv = 2
end
perfdata << " fail_count=#{failcount};;;; "

# Send appropriate code back.
final_rv = time_rv
if final_rv < failures_rv
  final_rv = failures_rv
end
puts "#{msg} | #{perfdata}"
exit final_rv
