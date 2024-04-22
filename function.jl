function euclidean_distance(cvrp, i, j)
    coord1_x = cvrp.coordinates[i, 1]
    coord1_y = cvrp.coordinates[i, 2]
    coord2_x = cvrp.coordinates[j, 1]
    coord2_y = cvrp.coordinates[j, 2]
    # @show i, j, coord1_x, coord1_y, coord2_x, coord2_y
    return round(sqrt((coord1_x - coord2_x)^2 + (coord1_y - coord2_y)^2))
end

function extend(label, vi, vj, cvrp, alpha, pi_i)
    Q, s_i, v, C = label
    new_Q = Q + cvrp.demand[vj]
    if new_Q > cvrp.capacity
        v[vj] = 1
        return nothing
    end
    new_s_i = s_i + 1
    new_v = copy(v)
    new_v[vj] = 1
    new_C = C + (euclidean_distance(cvrp, vi, vj) - alpha * pi_i[vj, 1])
    return (new_Q, new_s_i, new_v, new_C)
end

function dominates(label1::Tuple{Int64, Int64, Vector{Int64}, Real}, label2::Tuple{Int64, Int64, Vector{Int64}, Real})
    # @show label1, label2
    Q1, s1, v1, C1 = label1
    Q2, s2, v2, C2 = label2
    
    cost_dominates = C1 <= C2
    load_dominates = Q1 <= Q2
    v1 = label1[3]
    v2 = label2[3]
    visited_dominates = all(vi1 <= vi2 for (vi1, vi2) in zip(v1, v2))
    strictly_dominates = Q1 < Q2 || visited_dominates || C1 < C2

    return cost_dominates && load_dominates && visited_dominates && strictly_dominates
end

# function EFF(F::Vector{Tuple{Int64, Int64, Vector{Int64}, Float64}})
#     nondominated_labels = []

#     for label1 in F
#         if all(label2 -> !dominates(label1, label2), F)
#             push!(nondominated_labels, label1)
#         end
#     end

#     return nondominated_labels
# end

function EFF(F::Vector{Tuple{Int64, Int64, Vector{Int64}, Float64}}, labels::Vector{Tuple{Int64, Int64, Vector{Int64}, Float64}})
    nondominated_labels = []
    for label1 in F
        if all(label2 -> !dominates(label1, label2), labels)
            push!(nondominated_labels, label1)
        end
    end
    return nondominated_labels ∪ labels
end

function labels_have_changed(old_labels, new_labels)
    if length(old_labels) != length(new_labels)
        return true
    end
    for (old_label, new_label) in zip(old_labels, new_labels)
        if old_label != new_label
            return true
        end
    end
    return false
end