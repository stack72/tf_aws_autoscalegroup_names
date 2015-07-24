#!/usr/bin/ruby
require 'json'

profiles = []
File.open(File.expand_path('~/.aws/credentials'), 'r') do |f|
  f.each_line do |l|
    next unless l.gsub!(/^\[\s*(\w+)\s*\].*/, '\1')
    l.chomp!
    profiles.push(l)
  end
end

asg_hash = Hash.new

data = profiles.map do |account|
  regions_json = `aws ec2 describe-regions --profile #{account} --region us-east-1`
  if $?.exitstatus != 0
    print "Failed to run aws ec2 describe-regions --profile #{account}"
    exit 1
  end
  regions = JSON.parse(regions_json)['Regions'].map { |d| d['RegionName'] }
  regions.map do |region|
    asg_names = []
    asgs = `aws autoscaling describe-auto-scaling-groups --profile #{account} --region #{region}`
    if $?.exitstatus != 0
      print "Failed to run aws autoscaling describe-auto-scaling-groups --profile #{account} --region #{region}"
      exit 1
    end

    autoscalegroups = JSON.parse(asgs)
    autoscalegroups['AutoScalingGroups'].each do |asg|
        asg_names.push(asg['AutoScalingGroupName']) unless asg_names.include?(asg['AutoScalingGroupName'])
    end

    asg_hash.merge!(Hash["#{region}" => asg_names])
  end

end

output = {
   "variable" => {
   "autoscalegroup_names" => {
     "description" => "List of autoscalegroup names for a region",
     "default" => asg_hash
  }
}
}

File.open('variables.tf.json.new', 'w') { |f| f.puts JSON.pretty_generate(output) }
File.rename 'variables.tf.json.new', 'variables.tf.json'
