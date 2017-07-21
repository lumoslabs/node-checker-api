require 'sinatra'
require 'json'
require 'kubeclient'

get '/pod_status_by_node' do
  ssl_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
  auth_options = {
    bearer_token: File.read('/var/run/secrets/kubernetes.io/serviceaccount/token')
  }
  client = Kubeclient::Client.new('https://kubernetes/api/', "v1", ssl_options: ssl_options, auth_options: auth_options)

  # get the pods, grouped by nodeName
  pods = client.get_pods
  pods_by_node = pods.each_with_object({}) do |pod, h|
    h[pod.spec.nodeName] = {} if h[pod.spec.nodeName].nil?
    h[pod.spec.nodeName] << pod
  end

  node_states = {}
  pods_by_node.each do |node, pods|
    phases = pods.each_with_object(Hash.new(0)) { |pod,counts| counts[pod.status.phase] += 1 }
    node_states[node] = phases
  end
  node_states.to_json
end
