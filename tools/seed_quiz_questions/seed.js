/**
 * Constropedia — Firestore Quiz Questions Seeder
 *
 * Seeds 50 verified construction quiz questions (10 per category) into the
 * `quizQuestions` Firestore collection.
 *
 * Usage:
 *   1. Place your Firebase Admin service account JSON as serviceAccountKey.json
 *   2. npm install
 *   3. node seed.js
 *
 * This script is idempotent — safe to re-run.
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'constropedia-7d7a3',
});

const db = admin.firestore();

// ============================================================
// 50 QUIZ QUESTIONS — 10 per category
// ============================================================

const questions = [
  // ==================== MATERIALS ====================
  {
    id: 'mat_01',
    question: 'Which material is primarily used as a binder in concrete?',
    options: ['Cement', 'Sand', 'Coarse aggregate', 'Water'],
    correctAnswer: 'Cement',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      Cement: 'Cement acts as the binding material that holds all concrete ingredients together.',
      Sand: 'Sand is a fine aggregate providing bulk, not the binder.',
      'Coarse aggregate': 'Coarse aggregate gives structure but does not bind.',
      Water: 'Water activates the cement hydration but is not the binder itself.',
    },
  },
  {
    id: 'mat_02',
    question: 'What is the standard water-to-cement ratio for normal concrete?',
    options: ['0.4–0.6', '0.1–0.2', '0.8–1.0', '1.2–1.5'],
    correctAnswer: '0.4–0.6',
    category: 'Materials',
    difficulty: 'Medium',
    optionExplanations: {
      '0.4–0.6': 'A w/c ratio of 0.4–0.6 provides workability and adequate strength.',
      '0.1–0.2': 'Too low; the mix becomes unworkable.',
      '0.8–1.0': 'Too high; weakens concrete by increasing porosity.',
      '1.2–1.5': 'Far too high; produces very weak, porous concrete.',
    },
  },
  {
    id: 'mat_03',
    question: 'Which type of steel is commonly used as reinforcement in concrete structures?',
    options: ['Deformed bars (TMT)', 'Cast iron rods', 'Stainless steel wires', 'Galvanized mild steel sheets'],
    correctAnswer: 'Deformed bars (TMT)',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      'Deformed bars (TMT)': 'TMT deformed bars bond well with concrete and handle tensile forces.',
      'Cast iron rods': 'Cast iron is brittle and unsuitable for flexural reinforcement.',
      'Stainless steel wires': 'Used in prestressing but not standard RC reinforcement.',
      'Galvanized mild steel sheets': 'Sheets are not used as bar reinforcement.',
    },
  },
  {
    id: 'mat_04',
    question: 'What does OPC stand for in cement classification?',
    options: ['Ordinary Portland Cement', 'Optimum Pozzolanic Compound', 'Organic Portland Composite', 'Oxidised Portland Clinker'],
    correctAnswer: 'Ordinary Portland Cement',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      'Ordinary Portland Cement': 'OPC is the most widely used general-purpose cement.',
      'Optimum Pozzolanic Compound': 'Not a standard industry term.',
      'Organic Portland Composite': 'Incorrect; cement is mineral-based.',
      'Oxidised Portland Clinker': 'Incorrect expansion of the abbreviation.',
    },
  },
  {
    id: 'mat_05',
    question: 'Which additive is used to improve the workability of fresh concrete without adding extra water?',
    options: ['Plasticizer', 'Fly ash', 'Silica fume', 'Blast furnace slag'],
    correctAnswer: 'Plasticizer',
    category: 'Materials',
    difficulty: 'Medium',
    optionExplanations: {
      Plasticizer: 'Plasticizers (superplasticizers) improve flow without increasing the w/c ratio.',
      'Fly ash': 'Fly ash is a supplementary cementitious material, not primarily a workability aid.',
      'Silica fume': 'Silica fume increases strength and durability but reduces workability.',
      'Blast furnace slag': 'GGBS improves durability; it is not a plasticizer.',
    },
  },
  {
    id: 'mat_06',
    question: 'What is the main advantage of using fly ash in concrete?',
    options: ['Increases durability and reduces heat of hydration', 'Accelerates setting time', 'Increases unit weight', 'Reduces compressive strength'],
    correctAnswer: 'Increases durability and reduces heat of hydration',
    category: 'Materials',
    difficulty: 'Medium',
    optionExplanations: {
      'Increases durability and reduces heat of hydration': 'Fly ash reacts slowly, reducing heat and improving long-term durability.',
      'Accelerates setting time': 'Fly ash typically retards setting slightly.',
      'Increases unit weight': 'Fly ash is lighter and usually reduces unit weight.',
      'Reduces compressive strength': 'Properly used fly ash maintains or improves long-term strength.',
    },
  },
  {
    id: 'mat_07',
    question: 'Which test measures the workability (consistency) of fresh concrete?',
    options: ['Slump test', 'Rebound hammer test', 'Compression test', 'Tensile splitting test'],
    correctAnswer: 'Slump test',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      'Slump test': 'The slump test directly measures the consistency of fresh concrete.',
      'Rebound hammer test': 'Measures surface hardness of hardened concrete.',
      'Compression test': 'Measures compressive strength of hardened cubes or cylinders.',
      'Tensile splitting test': 'Measures indirect tensile strength of hardened concrete.',
    },
  },
  {
    id: 'mat_08',
    question: 'What is the nominal compressive strength of M25 concrete in MPa?',
    options: ['25 MPa', '15 MPa', '20 MPa', '30 MPa'],
    correctAnswer: '25 MPa',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      '25 MPa': 'M25 designates a characteristic compressive strength of 25 MPa at 28 days.',
      '15 MPa': 'That is M15 grade concrete.',
      '20 MPa': 'That is M20 grade concrete.',
      '30 MPa': 'That is M30 grade concrete.',
    },
  },
  {
    id: 'mat_09',
    question: 'Which aggregate property most affects the strength and density of concrete?',
    options: ['Particle shape and texture', 'Colour of aggregate', 'Moisture absorption of binder', 'Cement brand'],
    correctAnswer: 'Particle shape and texture',
    category: 'Materials',
    difficulty: 'Medium',
    optionExplanations: {
      'Particle shape and texture': 'Angular, rough-textured aggregates bond better and produce stronger concrete.',
      'Colour of aggregate': 'Colour has no meaningful effect on concrete strength.',
      'Moisture absorption of binder': 'Binder moisture is not an aggregate property.',
      'Cement brand': 'Cement brand is not an aggregate property.',
    },
  },
  {
    id: 'mat_10',
    question: 'What is the purpose of curing concrete after placement?',
    options: ['To maintain moisture for continued hydration', 'To increase water content', 'To speed up evaporation', 'To reduce cement content'],
    correctAnswer: 'To maintain moisture for continued hydration',
    category: 'Materials',
    difficulty: 'Easy',
    optionExplanations: {
      'To maintain moisture for continued hydration': 'Curing keeps concrete moist so cement particles continue to hydrate and gain strength.',
      'To increase water content': 'Curing is not about adding more water but preventing moisture loss.',
      'To speed up evaporation': 'Rapid evaporation during early curing causes cracking and weakness.',
      'To reduce cement content': 'Curing has no effect on cement content.',
    },
  },

  // ==================== STRUCTURAL ====================
  {
    id: 'str_01',
    question: 'What structural element transfers loads from slabs to columns?',
    options: ['Beam', 'Footing', 'Lintel', 'Parapet'],
    correctAnswer: 'Beam',
    category: 'Structural',
    difficulty: 'Easy',
    optionExplanations: {
      Beam: 'Beams span between columns and transfer slab loads via bending.',
      Footing: 'Footings are at the base and transfer column loads to soil.',
      Lintel: 'Lintels span openings such as doors and windows.',
      Parapet: 'Parapets are low protective walls above roof level.',
    },
  },
  {
    id: 'str_02',
    question: 'Which foundation type is used when soil bearing capacity is low across a large area?',
    options: ['Raft foundation', 'Strip foundation', 'Pad foundation', 'Pile foundation'],
    correctAnswer: 'Raft foundation',
    category: 'Structural',
    difficulty: 'Medium',
    optionExplanations: {
      'Raft foundation': 'A raft spreads the building load over the entire base area, reducing pressure on weak soil.',
      'Strip foundation': 'Strip footings run under load-bearing walls on reasonably competent soil.',
      'Pad foundation': 'Pad footings support individual columns on competent soil.',
      'Pile foundation': 'Piles transfer loads to deeper, stronger strata — different mechanism.',
    },
  },
  {
    id: 'str_03',
    question: 'What is the main function of shear walls in a building?',
    options: ['Resist lateral (wind and seismic) loads', 'Support roof loads only', 'Provide thermal insulation', 'Carry vertical gravity loads only'],
    correctAnswer: 'Resist lateral (wind and seismic) loads',
    category: 'Structural',
    difficulty: 'Medium',
    optionExplanations: {
      'Resist lateral (wind and seismic) loads': 'Shear walls act as vertical cantilevers to resist horizontal forces.',
      'Support roof loads only': 'Shear walls resist lateral forces; roof loads are carried by beams and columns.',
      'Provide thermal insulation': 'Thermal insulation is a building-envelope function.',
      'Carry vertical gravity loads only': 'Shear walls carry both lateral and gravity loads.',
    },
  },
  {
    id: 'str_04',
    question: 'Which structural system uses interconnected triangular units to distribute loads efficiently?',
    options: ['Truss', 'Flat slab', 'Grillage', 'Waffle slab'],
    correctAnswer: 'Truss',
    category: 'Structural',
    difficulty: 'Easy',
    optionExplanations: {
      Truss: 'Trusses use triangulated members so each member carries only axial (tension or compression) forces.',
      'Flat slab': 'A flat slab is a two-way slab system without beams.',
      Grillage: 'A grillage is a grid of beams, not triangulated.',
      'Waffle slab': 'A waffle slab has a grid of ribs on the underside for two-way spanning.',
    },
  },
  {
    id: 'str_05',
    question: 'What is the purpose of expansion joints in concrete structures?',
    options: ['Allow movement due to thermal expansion and settlement', 'Increase structural rigidity', 'Provide drainage', 'Increase compressive strength'],
    correctAnswer: 'Allow movement due to thermal expansion and settlement',
    category: 'Structural',
    difficulty: 'Medium',
    optionExplanations: {
      'Allow movement due to thermal expansion and settlement': 'Expansion joints prevent cracking by accommodating movement.',
      'Increase structural rigidity': 'Joints reduce rigidity; they are designed for flexibility.',
      'Provide drainage': 'Drainage is a separate design consideration.',
      'Increase compressive strength': 'Joints do not affect the compressive strength of concrete.',
    },
  },
  {
    id: 'str_06',
    question: 'In reinforced concrete design, steel is placed mainly at the tension zone because:',
    options: ['Concrete is weak in tension but strong in compression', 'Steel is cheaper than concrete', 'Steel has lower thermal conductivity', 'Concrete has high tensile strength'],
    correctAnswer: 'Concrete is weak in tension but strong in compression',
    category: 'Structural',
    difficulty: 'Easy',
    optionExplanations: {
      'Concrete is weak in tension but strong in compression': 'Steel compensates for concrete\'s low tensile strength (~1/10 of its compressive strength).',
      'Steel is cheaper than concrete': 'Steel is significantly more expensive per kg.',
      'Steel has lower thermal conductivity': 'Thermal conductivity is not the reason for steel placement.',
      'Concrete has high tensile strength': 'Concrete has very low tensile strength (~2–5 MPa).',
    },
  },
  {
    id: 'str_07',
    question: 'Which load acts horizontally on a retaining wall?',
    options: ['Lateral earth pressure', 'Dead load', 'Live load', 'Wind uplift'],
    correctAnswer: 'Lateral earth pressure',
    category: 'Structural',
    difficulty: 'Medium',
    optionExplanations: {
      'Lateral earth pressure': 'Retained soil exerts horizontal pressure on the back of a retaining wall.',
      'Dead load': 'Dead load acts vertically downward.',
      'Live load': 'Live load acts vertically due to occupancy.',
      'Wind uplift': 'Wind uplift acts upward on roofs, not primarily on retaining walls.',
    },
  },
  {
    id: 'str_08',
    question: 'What is the minimum clear cover required for reinforcement in a column exposed to mild conditions (IS 456)?',
    options: ['40 mm', '15 mm', '25 mm', '50 mm'],
    correctAnswer: '40 mm',
    category: 'Structural',
    difficulty: 'Hard',
    optionExplanations: {
      '40 mm': 'IS 456 specifies 40 mm nominal cover for columns in mild exposure.',
      '15 mm': '15 mm is the minimum for slabs in mild conditions.',
      '25 mm': '25 mm applies to beams in mild conditions.',
      '50 mm': '50 mm applies to severe or very severe exposure.',
    },
  },
  {
    id: 'str_09',
    question: 'Which structural failure mode involves a column crushing under compressive load?',
    options: ['Buckling and crushing', 'Shear failure', 'Torsional failure', 'Tensile splitting'],
    correctAnswer: 'Buckling and crushing',
    category: 'Structural',
    difficulty: 'Medium',
    optionExplanations: {
      'Buckling and crushing': 'Columns can fail by buckling (slender columns) or crushing (short columns) under axial compression.',
      'Shear failure': 'Shear failure is more common in beams under transverse loads.',
      'Torsional failure': 'Torsional failure involves twisting moments.',
      'Tensile splitting': 'Tensile splitting is a failure of concrete in tension.',
    },
  },
  {
    id: 'str_10',
    question: 'What is the purpose of stirrups in a reinforced concrete beam?',
    options: ['Resist shear forces and hold bars in position', 'Increase the moment capacity', 'Prevent thermal cracking', 'Replace longitudinal steel'],
    correctAnswer: 'Resist shear forces and hold bars in position',
    category: 'Structural',
    difficulty: 'Easy',
    optionExplanations: {
      'Resist shear forces and hold bars in position': 'Stirrups (links) confine longitudinal bars and resist diagonal shear cracks.',
      'Increase the moment capacity': 'Moment capacity is primarily increased by longitudinal bars.',
      'Prevent thermal cracking': 'Stirrups are a structural element, not a thermal control measure.',
      'Replace longitudinal steel': 'Stirrups complement longitudinal bars; they cannot replace them.',
    },
  },

  // ==================== FINISHING ====================
  {
    id: 'fin_01',
    question: 'Which coat of plaster is applied directly on a masonry surface?',
    options: ['Scratch coat', 'Brown coat', 'Finish coat', 'Render coat'],
    correctAnswer: 'Scratch coat',
    category: 'Finishing',
    difficulty: 'Medium',
    optionExplanations: {
      'Scratch coat': 'The scratch coat is the first plaster layer bonded to the substrate; it is scratched to key the next coat.',
      'Brown coat': 'The brown coat is the second, levelling coat.',
      'Finish coat': 'The finish coat is the final decorative layer.',
      'Render coat': 'Render coat is a general external finishing coat, not specifically the first coat.',
    },
  },
  {
    id: 'fin_02',
    question: 'What type of paint is best for interior walls in damp areas like bathrooms?',
    options: ['Epoxy or moisture-resistant emulsion', 'Distemper', 'Oil-based enamel', 'Whitewash'],
    correctAnswer: 'Epoxy or moisture-resistant emulsion',
    category: 'Finishing',
    difficulty: 'Easy',
    optionExplanations: {
      'Epoxy or moisture-resistant emulsion': 'These paints resist moisture and mould, making them suitable for wet areas.',
      Distemper: 'Distemper is water-soluble and not durable in damp conditions.',
      'Oil-based enamel': 'Enamel is durable but emits fumes; modern moisture-resistant emulsions are preferred.',
      Whitewash: 'Whitewash washes off easily in damp conditions.',
    },
  },
  {
    id: 'fin_03',
    question: 'What is the purpose of primer in a painting system?',
    options: ['Promote adhesion between surface and topcoat', 'Provide colour', 'Protect from UV radiation', 'Increase surface roughness only'],
    correctAnswer: 'Promote adhesion between surface and topcoat',
    category: 'Finishing',
    difficulty: 'Easy',
    optionExplanations: {
      'Promote adhesion between surface and topcoat': 'Primer seals the surface and creates a bond for subsequent coats.',
      'Provide colour': 'Colour is provided by the topcoat, not the primer.',
      'Protect from UV radiation': 'UV protection is primarily the topcoat\'s role.',
      'Increase surface roughness only': 'Primer reduces roughness and porosity while improving adhesion.',
    },
  },
  {
    id: 'fin_04',
    question: 'Which floor finishing material requires periodic sealing to maintain its appearance?',
    options: ['Natural stone (marble/granite)', 'Ceramic tile', 'Vinyl tile', 'Epoxy coating'],
    correctAnswer: 'Natural stone (marble/granite)',
    category: 'Finishing',
    difficulty: 'Medium',
    optionExplanations: {
      'Natural stone (marble/granite)': 'Natural stone is porous and requires sealing to prevent staining and moisture absorption.',
      'Ceramic tile': 'Glazed ceramic tiles are non-porous and do not require sealing.',
      'Vinyl tile': 'Vinyl is waterproof and does not require sealing.',
      'Epoxy coating': 'Epoxy is chemically resistant and does not need sealing.',
    },
  },
  {
    id: 'fin_05',
    question: 'What does the term "skirting" refer to in building finishing?',
    options: ['A finishing board at the base of a wall', 'A roof edge detail', 'A door frame moulding', 'A ceiling cornice'],
    correctAnswer: 'A finishing board at the base of a wall',
    category: 'Finishing',
    difficulty: 'Easy',
    optionExplanations: {
      'A finishing board at the base of a wall': 'Skirting (baseboard) covers the joint between floor and wall and protects the wall base.',
      'A roof edge detail': 'Roof edges use fascias and soffits.',
      'A door frame moulding': 'Door frame mouldings are called architraves or casings.',
      'A ceiling cornice': 'Ceiling cornices are at the junction of wall and ceiling.',
    },
  },
  {
    id: 'fin_06',
    question: 'What is terrazzo flooring made of?',
    options: ['Marble chips set in cement or epoxy matrix', 'Plain cement only', 'Ceramic powder mixed with water', 'Compressed clay tiles'],
    correctAnswer: 'Marble chips set in cement or epoxy matrix',
    category: 'Finishing',
    difficulty: 'Medium',
    optionExplanations: {
      'Marble chips set in cement or epoxy matrix': 'Terrazzo is marble or granite chips embedded in a binder, then polished.',
      'Plain cement only': 'Plain cement flooring is called cement screed or granolithic.',
      'Ceramic powder mixed with water': 'This describes ceramic tile production, not terrazzo.',
      'Compressed clay tiles': 'Compressed clay describes brick or quarry tile production.',
    },
  },
  {
    id: 'fin_07',
    question: 'Which finishing technique is used to create a smooth, hard, shiny plaster surface?',
    options: ['Polished plaster (Venetian plaster)', 'Sand-faced plaster', 'Pebble-dash render', 'Rough cast finish'],
    correctAnswer: 'Polished plaster (Venetian plaster)',
    category: 'Finishing',
    difficulty: 'Medium',
    optionExplanations: {
      'Polished plaster (Venetian plaster)': 'Venetian plaster is trowelled and burnished to a high gloss.',
      'Sand-faced plaster': 'Sand-faced plaster has a textured, sandy surface.',
      'Pebble-dash render': 'Pebble dash has exposed aggregate thrown onto wet render.',
      'Rough cast finish': 'Rough cast is a coarse textured exterior render.',
    },
  },
  {
    id: 'fin_08',
    question: 'What is the minimum curing time generally recommended for plaster before painting?',
    options: ['28 days', '1 day', '3 days', '7 days'],
    correctAnswer: '28 days',
    category: 'Finishing',
    difficulty: 'Hard',
    optionExplanations: {
      '28 days': 'Plaster needs about 28 days to fully cure and dry before paint is applied for best adhesion.',
      '1 day': 'Far too short; fresh plaster is still wet and alkaline.',
      '3 days': 'Too short; painting too early causes peeling.',
      '7 days': 'Some primers allow painting at 7 days but 28 days is the full recommendation.',
    },
  },
  {
    id: 'fin_09',
    question: 'Which type of glass is used for safety applications due to its shattering into small, harmless pieces?',
    options: ['Tempered (toughened) glass', 'Float glass', 'Wired glass', 'Laminated glass'],
    correctAnswer: 'Tempered (toughened) glass',
    category: 'Finishing',
    difficulty: 'Easy',
    optionExplanations: {
      'Tempered (toughened) glass': 'Tempered glass breaks into small, blunt-edged granules rather than sharp shards.',
      'Float glass': 'Float glass breaks into sharp shards and is not a safety glass by itself.',
      'Wired glass': 'Wired glass holds together when broken but is not classified as safety glass.',
      'Laminated glass': 'Laminated glass holds together due to the interlayer; also a safety glass but different mechanism.',
    },
  },
  {
    id: 'fin_10',
    question: 'What is the purpose of an expansion gap when installing hardwood flooring?',
    options: ['Allow wood to expand and contract with humidity changes', 'Improve acoustic insulation', 'Increase structural strength', 'Allow adhesive to set'],
    correctAnswer: 'Allow wood to expand and contract with humidity changes',
    category: 'Finishing',
    difficulty: 'Easy',
    optionExplanations: {
      'Allow wood to expand and contract with humidity changes': 'Wood is hygroscopic; without expansion gaps, floors can buckle.',
      'Improve acoustic insulation': 'Acoustic performance is addressed by underlay, not expansion gaps.',
      'Increase structural strength': 'Expansion gaps slightly reduce structural continuity.',
      'Allow adhesive to set': 'Gaps around the perimeter are not required for adhesive setting.',
    },
  },

  // ==================== SITE SAFETY ====================
  {
    id: 'saf_01',
    question: 'What colour is a mandatory action safety sign (e.g., "wear hard hat")?',
    options: ['Blue', 'Red', 'Yellow', 'Green'],
    correctAnswer: 'Blue',
    category: 'Site Safety',
    difficulty: 'Easy',
    optionExplanations: {
      Blue: 'Blue circular signs indicate mandatory actions (must do).',
      Red: 'Red signs indicate prohibition (must not do) or fire equipment.',
      Yellow: 'Yellow/amber signs indicate warnings and cautions.',
      Green: 'Green signs indicate safe conditions or first aid.',
    },
  },
  {
    id: 'saf_02',
    question: 'What is the minimum height at which fall protection (edge protection or harness) is required on a construction site in most standards?',
    options: ['2 m (or 6 ft)', '5 m', '0.5 m', '10 m'],
    correctAnswer: '2 m (or 6 ft)',
    category: 'Site Safety',
    difficulty: 'Medium',
    optionExplanations: {
      '2 m (or 6 ft)': 'Most international standards (UK CDM, US OSHA for construction) require fall protection from 2 m/6 ft.',
      '5 m': 'Too high; falls from lower heights are equally fatal.',
      '0.5 m': 'Below typical thresholds for mandatory fall protection equipment.',
      '10 m': 'Far too high; fall protection is required at much lower heights.',
    },
  },
  {
    id: 'saf_03',
    question: 'What does PPE stand for?',
    options: ['Personal Protective Equipment', 'Public Protection Enforcement', 'Primary Project Equipment', 'Planned Protection Engineering'],
    correctAnswer: 'Personal Protective Equipment',
    category: 'Site Safety',
    difficulty: 'Easy',
    optionExplanations: {
      'Personal Protective Equipment': 'PPE includes helmets, gloves, boots, high-vis vests and eye protection.',
      'Public Protection Enforcement': 'Not a construction industry term.',
      'Primary Project Equipment': 'Not an industry term.',
      'Planned Protection Engineering': 'Not an industry term.',
    },
  },
  {
    id: 'saf_04',
    question: 'Which gas is most commonly responsible for asphyxiation in confined space entry on construction sites?',
    options: ['Carbon dioxide (CO₂) displacing oxygen', 'Nitrogen in ambient air', 'Water vapour', 'Argon'],
    correctAnswer: 'Carbon dioxide (CO₂) displacing oxygen',
    category: 'Site Safety',
    difficulty: 'Hard',
    optionExplanations: {
      'Carbon dioxide (CO₂) displacing oxygen': 'CO₂ from decomposition, curing or exhaust collects in low areas and displaces breathable oxygen.',
      'Nitrogen in ambient air': 'Nitrogen makes up 78% of normal air and is not a hazard in itself.',
      'Water vapour': 'Humidity does not cause asphyxiation.',
      Argon: 'Argon is an inert gas used in welding; not a primary site asphyxiation concern.',
    },
  },
  {
    id: 'saf_05',
    question: 'What is the purpose of a risk assessment on a construction site?',
    options: ['Identify hazards and determine control measures', 'Calculate project profitability', 'Measure concrete slump', 'Plan material deliveries'],
    correctAnswer: 'Identify hazards and determine control measures',
    category: 'Site Safety',
    difficulty: 'Easy',
    optionExplanations: {
      'Identify hazards and determine control measures': 'Risk assessments are legally required to systematically identify and mitigate hazards.',
      'Calculate project profitability': 'That is a financial/commercial function.',
      'Measure concrete slump': 'Slump testing is a quality control procedure.',
      'Plan material deliveries': 'That is a logistics/procurement function.',
    },
  },
  {
    id: 'saf_06',
    question: 'What is a permit-to-work system used for?',
    options: ['Authorise high-risk activities such as hot work, confined space entry and working at height', 'Issue employment contracts', 'Approve architectural drawings', 'Certify material delivery'],
    correctAnswer: 'Authorise high-risk activities such as hot work, confined space entry and working at height',
    category: 'Site Safety',
    difficulty: 'Medium',
    optionExplanations: {
      'Authorise high-risk activities such as hot work, confined space entry and working at height': 'A PTW is a formal safety document that controls and authorises dangerous activities.',
      'Issue employment contracts': 'Employment contracts are an HR function.',
      'Approve architectural drawings': 'Drawing approval is a design/planning function.',
      'Certify material delivery': 'Material delivery is a logistics function.',
    },
  },
  {
    id: 'saf_07',
    question: 'Which colour of hard hat typically indicates a site visitor or new worker on most UK/international sites?',
    options: ['White', 'Yellow', 'Orange', 'Red'],
    correctAnswer: 'White',
    category: 'Site Safety',
    difficulty: 'Medium',
    optionExplanations: {
      White: 'White helmets are commonly used for visitors, managers or supervisors.',
      Yellow: 'Yellow helmets are typically worn by general operatives and labourers.',
      Orange: 'Orange helmets are often worn by plant/crane operators.',
      Red: 'Red helmets are typically worn by safety officers on some sites.',
    },
  },
  {
    id: 'saf_08',
    question: 'What is the HIERARCHY of controls in safety management, from most to least effective?',
    options: ['Eliminate → Substitute → Engineering → Administrative → PPE', 'PPE → Administrative → Engineering → Substitute → Eliminate', 'Administrative → PPE → Engineering → Eliminate → Substitute', 'Substitute → Eliminate → PPE → Administrative → Engineering'],
    correctAnswer: 'Eliminate → Substitute → Engineering → Administrative → PPE',
    category: 'Site Safety',
    difficulty: 'Hard',
    optionExplanations: {
      'Eliminate → Substitute → Engineering → Administrative → PPE': 'Elimination of the hazard is most effective; PPE is the last resort.',
      'PPE → Administrative → Engineering → Substitute → Eliminate': 'Reversed; this lists least to most effective.',
      'Administrative → PPE → Engineering → Eliminate → Substitute': 'Incorrect ordering.',
      'Substitute → Eliminate → PPE → Administrative → Engineering': 'Incorrect ordering.',
    },
  },
  {
    id: 'saf_09',
    question: 'What type of fire extinguisher should NOT be used on electrical fires?',
    options: ['Water extinguisher', 'CO₂ extinguisher', 'Dry powder extinguisher', 'Class E extinguisher'],
    correctAnswer: 'Water extinguisher',
    category: 'Site Safety',
    difficulty: 'Easy',
    optionExplanations: {
      'Water extinguisher': 'Water conducts electricity and creates a severe electrocution hazard on live electrical fires.',
      'CO₂ extinguisher': 'CO₂ is safe for electrical fires; it does not conduct electricity.',
      'Dry powder extinguisher': 'Dry powder is safe for electrical fires but causes mess.',
      'Class E extinguisher': 'Class E (electrical) extinguishers are specifically rated for electrical fires.',
    },
  },
  {
    id: 'saf_10',
    question: 'What is the primary purpose of edge protection (guardrails, toe boards) on a construction site?',
    options: ['Prevent falls of persons and objects from elevated areas', 'Mark site boundaries', 'Support formwork', 'Provide weatherproofing'],
    correctAnswer: 'Prevent falls of persons and objects from elevated areas',
    category: 'Site Safety',
    difficulty: 'Easy',
    optionExplanations: {
      'Prevent falls of persons and objects from elevated areas': 'Guardrails prevent people from falling; toe boards prevent tools and materials from being kicked off.',
      'Mark site boundaries': 'Site boundaries are marked with hoardings and fencing.',
      'Support formwork': 'Formwork is supported by props and falsework.',
      'Provide weatherproofing': 'Weatherproofing is a separate building-envelope consideration.',
    },
  },

  // ==================== TOOLS & MACHINERY ====================
  {
    id: 'too_01',
    question: 'Which tool is used to check that a surface is perfectly horizontal?',
    options: ['Spirit level', 'Plumb bob', 'Try square', 'Steel tape'],
    correctAnswer: 'Spirit level',
    category: 'Tools & Machinery',
    difficulty: 'Easy',
    optionExplanations: {
      'Spirit level': 'A spirit level uses a bubble in a liquid-filled vial to indicate true horizontal.',
      'Plumb bob': 'A plumb bob indicates true vertical.',
      'Try square': 'A try square checks right angles (90°).',
      'Steel tape': 'A steel tape measures linear distances.',
    },
  },
  {
    id: 'too_02',
    question: 'What is a transit mixer (drum truck) used for on a construction site?',
    options: ['Transport and keep concrete in a mixed state during delivery', 'Mix dry cement and aggregate only', 'Compact soil layers', 'Excavate foundations'],
    correctAnswer: 'Transport and keep concrete in a mixed state during delivery',
    category: 'Tools & Machinery',
    difficulty: 'Easy',
    optionExplanations: {
      'Transport and keep concrete in a mixed state during delivery': 'The rotating drum prevents concrete from setting during transit from batching plant to site.',
      'Mix dry cement and aggregate only': 'Dry batching is done at the plant, not in the drum truck.',
      'Compact soil layers': 'Soil compaction uses rollers or vibrating plates.',
      'Excavate foundations': 'Excavation uses excavators or backhoes.',
    },
  },
  {
    id: 'too_03',
    question: 'Which equipment is used to consolidate freshly placed concrete and remove air voids?',
    options: ['Poker (immersion) vibrator', 'Plate compactor', 'Tamping rammer', 'Rotary drill'],
    correctAnswer: 'Poker (immersion) vibrator',
    category: 'Tools & Machinery',
    difficulty: 'Easy',
    optionExplanations: {
      'Poker (immersion) vibrator': 'Poker vibrators are inserted into concrete to consolidate it and eliminate trapped air.',
      'Plate compactor': 'Plate compactors compact soil and sub-base layers.',
      'Tamping rammer': 'Tamping rammers compact cohesive soils in confined areas.',
      'Rotary drill': 'A rotary drill creates holes in concrete or masonry.',
    },
  },
  {
    id: 'too_04',
    question: 'What is the purpose of a dumpy level (automatic level) on site?',
    options: ['Establish horizontal datum levels across the site', 'Plumb columns vertically', 'Measure soil compaction', 'Set out building corners'],
    correctAnswer: 'Establish horizontal datum levels across the site',
    category: 'Tools & Machinery',
    difficulty: 'Medium',
    optionExplanations: {
      'Establish horizontal datum levels across the site': 'A dumpy level provides a precise horizontal line of sight for levelling surveys.',
      'Plumb columns vertically': 'Column plumbing uses a theodolite or plumb bob.',
      'Measure soil compaction': 'Soil compaction is measured with a Proctor test or dynamic cone penetrometer.',
      'Set out building corners': 'Setting out corners requires a total station or theodolite.',
    },
  },
  {
    id: 'too_05',
    question: 'Which type of crane is mounted on rails and moves horizontally to cover large areas of a site?',
    options: ['Tower crane with travelling base', 'Mobile telescopic crane', 'Crawler crane', 'Gantry crane'],
    correctAnswer: 'Gantry crane',
    category: 'Tools & Machinery',
    difficulty: 'Medium',
    optionExplanations: {
      'Gantry crane': 'A gantry crane spans an area on rails and travels horizontally, covering the full area beneath.',
      'Tower crane with travelling base': 'Some tower cranes travel on rails, but gantry crane is the more specific answer.',
      'Mobile telescopic crane': 'Mobile cranes move on rubber tyres, not rails.',
      'Crawler crane': 'Crawler cranes move on tracks, not dedicated rails.',
    },
  },
  {
    id: 'too_06',
    question: 'What is the main advantage of a telescopic handler (telehandler) over a standard forklift on a construction site?',
    options: ['Extendable boom allows reaching higher and farther', 'Faster on-road travel speed', 'Lower purchase cost', 'Requires no operator certification'],
    correctAnswer: 'Extendable boom allows reaching higher and farther',
    category: 'Tools & Machinery',
    difficulty: 'Medium',
    optionExplanations: {
      'Extendable boom allows reaching higher and farther': 'The telescoping boom gives far greater reach than a standard counterbalance forklift.',
      'Faster on-road travel speed': 'Telehandlers are not designed for on-road speed.',
      'Lower purchase cost': 'Telehandlers are typically more expensive than standard forklifts.',
      'Requires no operator certification': 'Telehandler operators require specific training and certification.',
    },
  },
  {
    id: 'too_07',
    question: 'Which tool is used to cut ceramic or porcelain tiles precisely?',
    options: ['Tile cutter (score-and-snap) or wet diamond saw', 'Circular saw with wood blade', 'Jigsaw with standard blade', 'Hammer and cold chisel only'],
    correctAnswer: 'Tile cutter (score-and-snap) or wet diamond saw',
    category: 'Tools & Machinery',
    difficulty: 'Easy',
    optionExplanations: {
      'Tile cutter (score-and-snap) or wet diamond saw': 'Score-and-snap cutters handle straight cuts; wet diamond saws handle curves and hard tiles.',
      'Circular saw with wood blade': 'Wood blades cannot cut ceramic and will shatter tiles.',
      'Jigsaw with standard blade': 'Standard blades cannot cut ceramic tiles cleanly.',
      'Hammer and cold chisel only': 'This creates rough, uncontrolled breaks unsuitable for precise cuts.',
    },
  },
  {
    id: 'too_08',
    question: 'What is a total station used for in construction surveying?',
    options: ['Electronic distance and angle measurement for precise setting-out', 'Measuring soil moisture content', 'Sampling concrete cores', 'Testing pile load capacity'],
    correctAnswer: 'Electronic distance and angle measurement for precise setting-out',
    category: 'Tools & Machinery',
    difficulty: 'Medium',
    optionExplanations: {
      'Electronic distance and angle measurement for precise setting-out': 'A total station combines an EDM and theodolite for 3D coordinate measurement.',
      'Measuring soil moisture content': 'Soil moisture is measured with probes or oven-drying tests.',
      'Sampling concrete cores': 'Core sampling uses a diamond core drill.',
      'Testing pile load capacity': 'Pile testing uses static or dynamic load testing rigs.',
    },
  },
  {
    id: 'too_09',
    question: 'Which excavator attachment is most suitable for breaking reinforced concrete?',
    options: ['Hydraulic breaker (rock hammer)', 'Bucket', 'Auger', 'Grab'],
    correctAnswer: 'Hydraulic breaker (rock hammer)',
    category: 'Tools & Machinery',
    difficulty: 'Easy',
    optionExplanations: {
      'Hydraulic breaker (rock hammer)': 'A hydraulic breaker delivers high-impact blows to fracture concrete and rock.',
      Bucket: 'A bucket is for digging and loading loose material.',
      Auger: 'An auger drills holes for piles or foundations.',
      Grab: 'A grab picks up and moves bulk material.',
    },
  },
  {
    id: 'too_10',
    question: 'What safety check must be performed before operating a scaffold?',
    options: ['Inspection by a competent person and confirmation that the scaffold tag is valid', 'Weighing all components', 'Applying fresh paint', 'Calculating wind loads only'],
    correctAnswer: 'Inspection by a competent person and confirmation that the scaffold tag is valid',
    category: 'Tools & Machinery',
    difficulty: 'Medium',
    optionExplanations: {
      'Inspection by a competent person and confirmation that the scaffold tag is valid': 'Scaffolds must be inspected by a competent person and tagged before use, and after any event that may affect stability.',
      'Weighing all components': 'Individual component weighing is not a site inspection procedure.',
      'Applying fresh paint': 'Paint has no bearing on scaffold safety.',
      'Calculating wind loads only': 'Wind load is considered in design, not in the daily pre-use inspection.',
    },
  },
];

async function seed() {
  console.log(`Seeding ${questions.length} quiz questions to Firestore...`);
  const batch = db.batch();

  for (const q of questions) {
    const ref = db.collection('quizQuestions').doc(q.id);
    batch.set(ref, q);
  }

  await batch.commit();
  console.log(`✅ Successfully seeded ${questions.length} questions.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});

