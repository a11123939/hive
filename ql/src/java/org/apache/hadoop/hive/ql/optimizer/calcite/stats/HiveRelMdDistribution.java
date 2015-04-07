/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.hive.ql.optimizer.calcite.stats;

import org.apache.calcite.rel.RelDistribution;
import org.apache.calcite.rel.metadata.ChainedRelMetadataProvider;
import org.apache.calcite.rel.metadata.ReflectiveRelMetadataProvider;
import org.apache.calcite.rel.metadata.RelMdDistribution;
import org.apache.calcite.rel.metadata.RelMetadataProvider;
import org.apache.calcite.util.BuiltInMethod;
import org.apache.hadoop.hive.ql.optimizer.calcite.HiveCalciteUtil;
import org.apache.hadoop.hive.ql.optimizer.calcite.HiveCalciteUtil.JoinLeafPredicateInfo;
import org.apache.hadoop.hive.ql.optimizer.calcite.HiveCalciteUtil.JoinPredicateInfo;
import org.apache.hadoop.hive.ql.optimizer.calcite.HiveRelDistribution;
import org.apache.hadoop.hive.ql.optimizer.calcite.reloperators.HiveAggregate;
import org.apache.hadoop.hive.ql.optimizer.calcite.reloperators.HiveJoin;
import org.apache.hadoop.hive.ql.optimizer.calcite.reloperators.HiveJoin.MapJoinStreamingRelation;

import com.google.common.collect.ImmutableList;

public class HiveRelMdDistribution {

  public static final RelMetadataProvider SOURCE =
          ChainedRelMetadataProvider.of(
                  ImmutableList.of(
                          ReflectiveRelMetadataProvider.reflectiveSource(
                                  BuiltInMethod.DISTRIBUTION.method, new HiveRelMdDistribution()),
                          RelMdDistribution.SOURCE));
  
  //~ Constructors -----------------------------------------------------------

  private HiveRelMdDistribution() {}

  //~ Methods ----------------------------------------------------------------

  public RelDistribution distribution(HiveAggregate aggregate) {
    return new HiveRelDistribution(RelDistribution.Type.HASH_DISTRIBUTED,
            aggregate.getGroupSet().asList());
  }

  public RelDistribution distribution(HiveJoin join) {
    // Compute distribution
    ImmutableList.Builder<Integer> keysListBuilder =
            new ImmutableList.Builder<Integer>();
    ImmutableList.Builder<Integer> leftKeysListBuilder =
            new ImmutableList.Builder<Integer>();
    ImmutableList.Builder<Integer> rightKeysListBuilder =
            new ImmutableList.Builder<Integer>();
    JoinPredicateInfo joinPredInfo =
            HiveCalciteUtil.JoinPredicateInfo.constructJoinPredicateInfo(join);
    for (int i = 0; i < joinPredInfo.getEquiJoinPredicateElements().size(); i++) {
      JoinLeafPredicateInfo joinLeafPredInfo = joinPredInfo.
          getEquiJoinPredicateElements().get(i);
      for (int leftPos : joinLeafPredInfo.getProjsFromLeftPartOfJoinKeysInJoinSchema()) {
        keysListBuilder.add(leftPos);
        leftKeysListBuilder.add(leftPos);        
      }
      for (int rightPos : joinLeafPredInfo.getProjsFromRightPartOfJoinKeysInJoinSchema()) {
        keysListBuilder.add(rightPos);
        rightKeysListBuilder.add(rightPos);        
      }
    }

    RelDistribution distribution;
    switch (join.getJoinAlgorithm()) {
      case SMB_JOIN:
      case BUCKET_JOIN:
      case COMMON_JOIN:
        distribution = new HiveRelDistribution(
                RelDistribution.Type.HASH_DISTRIBUTED, keysListBuilder.build());
        break;
      case MAP_JOIN:
        // Keep buckets from the streaming relation
        if (join.getMapJoinStreamingSide() == MapJoinStreamingRelation.LEFT_RELATION) {
          distribution = new HiveRelDistribution(
                  RelDistribution.Type.HASH_DISTRIBUTED, leftKeysListBuilder.build());
        } else if (join.getMapJoinStreamingSide() == MapJoinStreamingRelation.RIGHT_RELATION) {
          distribution = new HiveRelDistribution(
                  RelDistribution.Type.HASH_DISTRIBUTED, rightKeysListBuilder.build());
        } else {
          distribution = null;
        }
        break;
      default:
        distribution = null;
    }
    return distribution;
  }

}
