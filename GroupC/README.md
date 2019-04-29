# Investigating Ambulance Response Time
## CUSP London Data Drive 2019 with the London Ambulance Service

#### Group Members:
Jiaxu Wu,
Kent Pan,
Jack Humble,
Aparajita Haldar,
Nadezda Leonova,
Matteo Mazzamurro

#### Research Questions:
- How can we reduce response times that are unusually high among C1 and C2 incidents? 
- What contributes the most to unusually high response times?
- Are there temporal or spatial patterns affecting ambulance response time? What focus areas have the biggest impact on response time improvements?
- Can live traffic information help determine best choice of ambulance for dispatch?

#### Different phases of the ambulance trip where real-time data is beneficial:
- Decide which ambulance to dispatch (activation time) - _we identify (spatially and temporally) in which situations this choice is most crucial_
- Travel to scene of incident (mobilisation & running time) - _we identify (spatially and temporally) in which situations this is most affected_
- On-scene & hospital time - _needs hospital staff/resource availability real-time data_
- Ambulance relocation before next dispatch (idle time) - _we demonstrate some ideas to compute this as future work_

#### Findings and Recommendations:
- For long response times, primary factor is the **activation (dispatch) time**, which is dependent on staffing & **crew availability** (no available crews to dispatch)
- The next focus is improving **running time**, which is more controllable, and has cascade effects. This is highly affected by **dispatch decisions**.
  - Strategy 1: Most crucial around rush hour as congestion patterns affect travel time significantly. Hence, temporally speaking, rush hour is when it is important to dispatch the correct ambulance according to actual live traffic updated travel time. 
  - Strategy 2: More crucial around the boundary of the Greater London service area, as travel times vary wildly for the different options of ambulance start points. Hence, spatially speaking, when dispatching to the outskirts, eyeballing the proximity on a map is misleading and exact route-mapping with real-time traffic is very beneficial.
- Moreover, after a patient has been handed over to a hospital/emergency service, **ambulance relocation** could improve response time to future calls. The average **idle time** between calls for an ambulance is nearly 5 mins. 
  - Strategy 1: gravitational model based on places where incidents are more likely to occur (would benefit average rather than queues) _for any current LSOA ambulance location, we can suggest the direction of that wards most incident-prone LSOA_
  - Strategy 2: move reasonably ambulances to places from which they can reach the outskirts (target the queues, while keeping the average in target) _for any current LSOA, we can suggest which direction of approach is fastest, that is, do amulances arrive faster on average if they are arriving at this scene from the north-west or the south or so on_
  
#### Future Work:
- Neglected boundary effects: Given data on incidents happening within London boundaries but dealt with by other ambulance services, we can refine our analysis of the response times at the outskirts
- Ambulance choice at dispatch: Given data on location of all ambulances which were available to respond to a given incident, we can use this real data rather than synthetically generated data
- Ambulance trajectory over one day: Given data to connect ambulances to their home station, and data to identify location of the hospital where a patient has been handed over, we can map exactly how an ambulance might get drawn away from the areas it should ideally be servicing, and the reasons for this


