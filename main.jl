include("function.jl")
using CSV
using DataFrames
using CVRPLIB
# Assuming the data has been loaded using the CVRPLIB package
cvrp, vrp_file, sol_file = readCVRPLIB("P-n16-k8")
pi_i = CSV.read("dual_var_P-n16-k8.csv", DataFrame, header = false)

# Define the number of nodes based on the data loaded
p = 1  # Assuming node 1 is the starting node for the ESPPRC problem
alpha = 1.3
# Initialize labels for all nodes with n_nodes and start node 'p'
labels = Dict{Int, Array{Tuple{Int, Int, Vector{Int}, Float64}, 1}}()
# @show labels
for node in 1:cvrp.dimension 
    labels[node] = []
end
# @show labels
# The start node gets a label with zero cumulative demand (Q), summation of v (s_i), 
# n_nodes of 0s for visited status (v), and zero cumulative cost (C)
labels[p] = [(0, 0, [0 for _ in 1:cvrp.dimension], 0.0)]
# @show labels
# Initialize set E with start node 'p'
E = Set([p])
# @show E

# Main loop of the ESPPRC algorithm
while !isempty(E)
    # Choose a node from E
    # vi = pop!(E)
    vi = first(E)
    # Explore successors of the chosen node
    for vj in 1:cvrp.dimension
    # if vi != vj
        # @show vj
        Fij = Tuple{Int64, Int64, Vector{Int64}, Float64}[]
        # Attempt to extend labels to the successor node
        for label in labels[vi]
            if label[3][vj] == 0
                extended_label = extend(label, vi, vj, cvrp, alpha, pi_i)
                # @show extended_label
                if extended_label == nothing
                    continue
                end
                # if all(extended_label[3] .== 1)
                #     # Send the vehicle back to node 1
                #     extended_label[2] += 1
                #     # Add the Euclidean distance from the current node to node 1 to C
                #     extended_label[4] += euclidean_distance(cvrp, vj, 1)
                # end
                push!(Fij, extended_label)
            end
        end

        # Update labels for node vj using EFF function
        old_labels_vj = labels[vj]
        labels[vj] = EFF(Fij ∪ labels[vj])

        # If labels for vj have changed, add vj to E
        if labels_have_changed(old_labels_vj, labels[vj])
            push!(E, vj) # 이게 되고 있는지?
        end

    # Remove vi from E
    delete!(E, vi)
    end
end

@show labels