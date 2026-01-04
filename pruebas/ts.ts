
enum Dimension {
  weight,
  volume,
  count,
}
enum Unit {
  gram = "gram", kilogram = "kilogram", milliliter = "milliliter", liter = "liter",
  tbsp = "tablespoon", tsp = "teaspoon", cup = "cup", piece = "piece"
}

class UnitDefinition {
  unit: Unit;
  dimension: Dimension;
  toBaseFactor: number;

  constructor({
    unit,
    dimension,
    toBaseFactor,
  }: {
    unit: Unit;
    dimension: Dimension;
    toBaseFactor: number;
  }) {
    this.unit = unit;
    this.dimension = dimension;
    this.toBaseFactor = toBaseFactor;
  };
}


class Ingredient {
  id: number;
  name: string;
  density: number; // g por ml

  constructor({
    id,
    name,
    density,
  }: {
    id: number;
    name: string;
    density: number;
  }) {
    this.id = id;
    this.name = name;
    this.density = density;
  };
}



class IngredientsServices {
  ingredients: Ingredient[] = [
    new Ingredient({
      id:1, name:"harina de avena fina", density:0.46,
    }),
    new Ingredient({
      id:1, name:"harina de avena", density:0.42,
    })
  ];

  async getIngredient(ingredientId: number): Promise<Ingredient | undefined> {
    return this.ingredients.find(ingredient => ingredient.id == ingredientId);
  }
}

const unitDefinitions: Record<Unit, UnitDefinition> = {
  [Unit.gram]: new UnitDefinition(
    {
      unit: Unit.gram,
      dimension: Dimension.weight,
      toBaseFactor: 1,
    }
  ),
  [Unit.kilogram]: new UnitDefinition(
    {
      unit: Unit.kilogram,
      dimension: Dimension.weight,
      toBaseFactor: 1000,
    }
  ),
  [Unit.milliliter]: new UnitDefinition(
    {
      unit: Unit.milliliter,
      dimension: Dimension.volume,
      toBaseFactor: 1,
    }
  ),
  [Unit.cup]: new UnitDefinition(
    {
      unit: Unit.cup,
      dimension: Dimension.volume,
      toBaseFactor: 240,
    }
  ),
  [Unit.liter]: new UnitDefinition(
    {
      unit: Unit.liter,
      dimension: Dimension.volume,
      toBaseFactor: 1000,
    }
  ),
  [Unit.tbsp]: new UnitDefinition(
    {
      unit: Unit.tbsp,
      dimension: Dimension.volume,
      toBaseFactor: 14.7868,
    }
  ),
  [Unit.tsp]: new UnitDefinition(
    {
      unit: Unit.tsp,
      dimension: Dimension.volume,
      toBaseFactor: 4.92892,
    }
  ),
  [Unit.piece]: new UnitDefinition(
    {
      unit: Unit.piece,
      dimension: Dimension.count,
      toBaseFactor: 1,
    }
  ),
};

class UnitRepository {
  get(unit: Unit) {
    return unitDefinitions[unit];
  }
}

type TConvertProps = {
    value: number,
    from: Unit,
    to: Unit,
    ingredient: Ingredient | undefined,
  }
class RecipeUnitConverter {
  private unitRepo: UnitRepository;

  constructor(unitRepo: UnitRepository) {
    this.unitRepo = unitRepo;
  }


  async convert({ value, from, to, ingredient }: TConvertProps): Promise<number> {
    const fromDef = this.unitRepo.get(from);
    const toDef = this.unitRepo.get(to);

    if (fromDef.dimension == toDef.dimension) {
      return this._convertSameDimension(value, fromDef, toDef);
    }

    if (fromDef.dimension == Dimension.volume &&
      toDef.dimension == Dimension.weight) {
      if (!ingredient) {
        throw Error('Ingredient required');
      }
      return this._convertVolumeToWeight(value, fromDef, toDef, ingredient);
    }

    throw Error('Conversion not supported');
  }


  private _convertSameDimension(
    value: number,
    from: UnitDefinition,
    to: UnitDefinition,
  ): number {
    const base = value * from.toBaseFactor;
    return base / to.toBaseFactor;
  }

  private _convertVolumeToWeight(
    value: number,
    from: UnitDefinition,
    to: UnitDefinition,
    ingredient: Ingredient,
  ): number {
    const ml = value * from.toBaseFactor;
    const grams = ml * ingredient.density;
    return grams / to.toBaseFactor;
  }
}

const recipeUnitConverter = new RecipeUnitConverter(new UnitRepository());
recipeUnitConverter.convert({
  value: 1,
  from: Unit.cup,
  to: Unit.gram,
  ingredient: new Ingredient({
      id:1, name:"harina de avena fina", density:0.46,
    })
})