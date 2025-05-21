import Foundation

struct CharacterTrait: Identifiable {
    var id = UUID() // Unique identifier for each character
    var name: String // Character's name
    var gender: String // Character's gender
    var backstory: String // Character's backstory
    var age: Int // Character's age
    var ancestryPercentage: [String: Double] // Ancestry and their percentages
    var emotionalMaturity: Double
    var physicality: [String: Double] // Traits like strength, agility, etc.
    var personalityTraits: [String: Double] // Big Five Personality Traits
    var lifeExperiences: [String: Double] // Life events and their impacts
    var moralAlignment: Double
    var interests: [String: Double] // Hobbies and interests
    var careerSkills: [String: Double] // Professional skills
    var socialRelationships: [String: Double] // Family, friends, romantic relations
    var psychologicalComplexities: [String: Double] // Fears, ambitions, mental health

    init(
        name: String = "John Doe",
        gender: String = "Non-binary",
        backstory: String = "An enigmatic figure with a mysterious past.",
        age: Int = 30,
        ancestryPercentage: [String: Double] = ["Asian": 0.5, "European": 0.5],
        emotionalMaturity: Double = 0.5,
        physicality: [String: Double] = ["Strength": 0.5, "Agility": 0.5],
        personalityTraits: [String: Double] = ["Openness": 0.5, "Conscientiousness": 0.5],
        lifeExperiences: [String: Double] = ["Education": 0.5, "Travel": 0.5],
        moralAlignment: Double = 0.5,
        interests: [String: Double] = ["Art": 0.5, "Science": 0.5],
        careerSkills: [String: Double] = ["Communication": 0.5, "Technical": 0.5],
        socialRelationships: [String: Double] = ["Family": 0.5, "Friends": 0.5],
        psychologicalComplexities: [String: Double] = ["Fears": 0.5, "Ambitions": 0.5]
    ) {
        self.name = name
        self.gender = gender
        self.backstory = backstory
        self.age = age
        self.ancestryPercentage = ancestryPercentage
        self.emotionalMaturity = emotionalMaturity
        self.physicality = physicality
        self.personalityTraits = personalityTraits
        self.lifeExperiences = lifeExperiences
        self.moralAlignment = moralAlignment
        self.interests = interests
        self.careerSkills = careerSkills
        self.socialRelationships = socialRelationships
        self.psychologicalComplexities = psychologicalComplexities
    }
}
