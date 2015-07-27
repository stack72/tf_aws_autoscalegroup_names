#!/usr/bin/ruby
require 'json'
require 'optparse'

options = {:aws_account => 'default' }

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: getvariables.rb [options]"
  opts.on('-a','--aws-account aws_account', 'AWS Account Name') do |aws_account|
    options[:aws_account] = aws_account
  end
  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

optparse.parse!

profiles = options[:aws_account].split(',')

asg_hash = Hash.new

data = profiles.map do |account|
  regions_json = `aws ec2 describe-regions --profile #{account} --region us-east-1`
  if $?.exitstatus != 0
    print "Failed to run aws ec2 describe-regions --profile #{account}"
    exit 1
  end
  regions = JSON.parse(regions_json)['Regions'].map { |d| d['RegionName'] }
  regions.map do |region|
    asgs_list = []
    asgs = `aws autoscaling describe-auto-scaling-groups --profile #{account} --region #{region}`
    if $?.exitstatus != 0
      print "Failed to run aws autoscaling describe-auto-scaling-groups --profile #{account} --region #{region}"
      exit 1
    end

    autoscalegroups = JSON.parse(asgs)
    autoscalegroups['AutoScalingGroups'].each do |asg|
        asgs_list.push(asg['AutoScalingGroupName']) unless asgs_list.include?(asg['AutoScalingGroupName'])
    end

    asg_hash.merge!(Hash["#{region}" => asgs_list.join(",")])
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
