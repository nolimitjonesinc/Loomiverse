import SwiftUI
struct CharacterCreationView: View {
    @State private var character = CharacterTrait(
        ancestryPercentage: ["Asian": 0.5, "European": 0.5, "African": 0.5, "Native American": 0.5, "Latin American": 0.5, "Middle Eastern": 0.5, "Pacific Islander": 0.5],
        emotionalMaturity: 0.5,
        physicality: ["Strength": 0.5, "Agility": 0.5, "Body Type": 0.5, "Height": 0.5, "Hair Color": 0.5, "Eye Color": 0.5],
        personalityTraits: ["Openness": 0.5, "Conscientiousness": 0.5, "Extraversion": 0.5, "Agreeableness": 0.5, "Neuroticism": 0.5],
        lifeExperiences: ["Education": 0.5, "Trauma": 0.5, "Career Achievement": 0.5, "Travel": 0.5, "Family Milestones": 0.5],
        moralAlignment: 0.5,
        interests: ["Art": 0.5, "Science": 0.5, "Sports": 0.5, "Music": 0.5, "Gaming": 0.5, "Travel": 0.5, "Cooking": 0.5],
        careerSkills: ["Communication": 0.5, "Technical": 0.5, "Leadership": 0.5, "Artistic": 0.5, "Scientific": 0.5],
        socialRelationships: ["Family": 0.5, "Friends": 0.5, "Romantic": 0.5, "Professional": 0.5, "Community": 0.5],
        psychologicalComplexities: ["Fears": 0.5, "Ambitions": 0.5, "Optimism": 0.5, "Introversion": 0.5, "Resilience": 0.5]
    )
    // State variables for each category's expanded/collapsed state
    @State private var isAncestryExpanded = true
    @State private var isEmotionalMaturityExpanded = true
    @State private var isPhysicalityExpanded = true
    @State private var isPersonalityExpanded = true
    @State private var isLifeExperiencesExpanded = true
    @State private var isMoralAlignmentExpanded = true
    @State private var isInterestsExpanded = true
    @State private var isCareerSkillsExpanded = true
    @State private var isSocialRelationshipsExpanded = true
    @State private var isPsychologicalComplexitiesExpanded = true
    private func adjustAncestryPercentages(changedKey: String, newValue: Double) {
        let totalPercentage = character.ancestryPercentage.values.reduce(0, +)
        let excessPercentage = totalPercentage - 1
        let keysToAdjust = character.ancestryPercentage.keys.filter { $0 != changedKey }
        for key in keysToAdjust {
            character.ancestryPercentage[key, default: 0.5] -= excessPercentage / Double(keysToAdjust.count)
        }
        // Ensure values are within 0 to 1 range
        for key in character.ancestryPercentage.keys {
            character.ancestryPercentage[key] = min(max(character.ancestryPercentage[key, default: 0.5], 0), 1)
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Customize Your Character").font(.headline)
                // Randomize Button at the top
                Button("Randomize Character") {
                    randomizeCharacterTraits()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                // Each trait category within a DisclosureGroup
                DisclosureGroup("Ancestral Background", isExpanded: $isAncestryExpanded) {
                    ForEach(character.ancestryPercentage.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.ancestryPercentage[key, default: 0.5] }, set: { character.ancestryPercentage[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Emotional Maturity", isExpanded: $isEmotionalMaturityExpanded) {
                    SliderWithTitle(sliderValue: $character.emotionalMaturity, title: "Emotional Maturity", range: 0...1)
                }
                DisclosureGroup("Physicality", isExpanded: $isPhysicalityExpanded) {
                    ForEach(character.physicality.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.physicality[key, default: 0.5] }, set: { character.physicality[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Personality Traits", isExpanded: $isPersonalityExpanded) {
                    ForEach(character.personalityTraits.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.personalityTraits[key, default: 0.5] }, set: { character.personalityTraits[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Life Experiences", isExpanded: $isLifeExperiencesExpanded) {
                    ForEach(character.lifeExperiences.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.lifeExperiences[key, default: 0.5] }, set: { character.lifeExperiences[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Moral Alignment", isExpanded: $isMoralAlignmentExpanded) {
                    SliderWithTitle(sliderValue: $character.moralAlignment, title: "Moral Alignment", range: 0...1)
                }
                DisclosureGroup("Interests and Hobbies", isExpanded: $isInterestsExpanded) {
                    ForEach(character.interests.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.interests[key, default: 0.5] }, set: { character.interests[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Career and Skills", isExpanded: $isCareerSkillsExpanded) {
                    ForEach(character.careerSkills.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.careerSkills[key, default: 0.5] }, set: { character.careerSkills[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Social Relationships", isExpanded: $isSocialRelationshipsExpanded) {
                    ForEach(character.socialRelationships.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.socialRelationships[key, default: 0.5] }, set: { character.socialRelationships[key] = $0 }), title: key, range: 0...1)
                    }
                }
                DisclosureGroup("Psychological Complexities", isExpanded: $isPsychologicalComplexitiesExpanded) {
                    ForEach(character.psychologicalComplexities.keys.sorted(), id: \.self) { key in
                        SliderWithTitle(sliderValue: Binding(get: { character.psychologicalComplexities[key, default: 0.5] }, set: { character.psychologicalComplexities[key] = $0 }), title: key, range: 0...1)
                    }
                }
            }
            .padding()
        }
    }
    private func randomizeCharacterTraits() {
        // Randomize all traits
        for key in character.ancestryPercentage.keys {
            character.ancestryPercentage[key] = Double.random(in: 0...1)
        }
        // Normalize the percentages so that they add up to 1 (100%)
        let totalPercentage = character.ancestryPercentage.values.reduce(0, +)
        for key in character.ancestryPercentage.keys {
            if let currentValue = character.ancestryPercentage[key] {
                character.ancestryPercentage[key] = currentValue / totalPercentage
            }
        }
        // Randomize all traits
        character.ancestryPercentage["Asian"] = Double.random(in: 0...1)
        character.ancestryPercentage["African"] = Double.random(in: 0...1)
        character.ancestryPercentage["European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Latin American"] = Double.random(in: 0...1)
        character.ancestryPercentage["Middle Eastern"] = Double.random(in: 0...1)
        character.ancestryPercentage["Native American"] = Double.random(in: 0...1)
        character.ancestryPercentage["Pacific Islander"] = Double.random(in: 0...1)
        character.ancestryPercentage["East Asian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Southeast Asian"] = Double.random(in: 0...1)
        character.ancestryPercentage["South Asian"] = Double.random(in: 0...1)
        character.ancestryPercentage["West African"] = Double.random(in: 0...1)
        character.ancestryPercentage["East African"] = Double.random(in: 0...1)
        character.ancestryPercentage["North African"] = Double.random(in: 0...1)
        character.ancestryPercentage["Central African"] = Double.random(in: 0...1)
        character.ancestryPercentage["Southern African"] = Double.random(in: 0...1)
        character.ancestryPercentage["Northern European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Eastern European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Southern European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Western European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Caribbean"] = Double.random(in: 0...1)
        character.ancestryPercentage["Latin American"] = Double.random(in: 0...1)
        character.ancestryPercentage["Middle Eastern"] = Double.random(in: 0...1)
        character.ancestryPercentage["Central Asian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Native American"] = Double.random(in: 0...1)
        character.ancestryPercentage["Pacific Islander"] = Double.random(in: 0...1)
        character.ancestryPercentage["Australian Aboriginal"] = Double.random(in: 0...1)
        character.ancestryPercentage["Siberian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Melanesian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Polynesian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Micronesian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Scandinavian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Baltic"] = Double.random(in: 0...1)
        character.ancestryPercentage["Balkan"] = Double.random(in: 0...1)
        character.ancestryPercentage["Iberian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Caucasian"] = Double.random(in: 0...1)
        character.ancestryPercentage["Indo-European"] = Double.random(in: 0...1)
        character.ancestryPercentage["Ainu"] = Double.random(in: 0...1)
        // Continue randomizing for other ancestries and traits...
        character.emotionalMaturity = Double.random(in: 0...1)
        character.physicality["Strength"] = Double.random(in: 0...1)
        character.personalityTraits["Openness"] = Double.random(in: 0...1)
        character.lifeExperiences["Education"] = Double.random(in: 0...1)
        character.moralAlignment = Double.random(in: 0...1)
        character.interests["Art"] = Double.random(in: 0...1)
        character.careerSkills["Communication"] = Double.random(in: 0...1)
        character.socialRelationships["Family"] = Double.random(in: 0...1)
        character.psychologicalComplexities["Fears"] = Double.random(in: 0...1)
    }
}
struct SliderWithTitle: View {
    @Binding var sliderValue: Double
    var title: String
    var range: ClosedRange<Double>
    var body: some View {
        VStack {
            Text("\(title): \(sliderValue, specifier: "%.2f")")
            Slider(value: $sliderValue, in: range)
        }
    }
}
