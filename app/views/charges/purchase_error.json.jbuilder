json.status 'error'
json.message 'Node price is 0. Purchase rejected.'
json.node do
  json.partial! 'nodes/node', node: @node
end
