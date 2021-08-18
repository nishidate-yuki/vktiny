#pragma once
#include "vktiny/Vulkan/Buffer.hpp"
#include "vktiny/Vulkan/Image.hpp"
#include "vktiny/Vulkan/AccelStruct.hpp"
#include "vktiny/Vulkan/Context.hpp"
#include <unordered_map>

namespace vkt
{
    class DescriptorManager
    {
    public:
        using vkDT = vk::DescriptorType;
        using vkSS = vk::ShaderStageFlagBits;

        void initialize(const Context& context);

        void prepare(uint32_t maxSets = 1);

        // TODO: create multi sets
        void addStorageBuffer(Buffer& buffer, uint32_t binding, uint32_t set = 0)
        {
            addDescriptor(vkDT::eStorageBuffer, buffer.createWrite(), binding);
        }

        void addUniformBuffer(Buffer& buffer, uint32_t binding, uint32_t set = 0)
        {
            addDescriptor(vkDT::eUniformBuffer, buffer.createWrite(), binding);
        }

        void addStorageImage(Image& image, uint32_t binding, uint32_t set = 0)
        {
            addDescriptor(vkDT::eStorageImage, image.createWrite(), binding);
        }

        void addTopLevelAccelStruct(TopLevelAccelStruct& topLevelAS, uint32_t binding, uint32_t set = 0)
        {
            addDescriptor(vkDT::eAccelerationStructureKHR, topLevelAS.createWrite(), binding);
        }

        //void addCombinedImageSamplers(std::)
        //{
        //    combinedImageSamplers.insert(combinedImageSamplers.end(), b.begin(), b.end());
        //    vkDT::eCombinedImageSampler
        //}

        const auto& getDescSet() const { return *descSets.front(); }
        const auto& getDescSetLayout() const { return *descSetLayout; }

    private:
        void addDescriptor(vk::DescriptorType type, vk::WriteDescriptorSet write, uint32_t binding);

        const Device* device;
        const PhysicalDevice* physicalDevice;

        // Descriptor
        void createDescriptorPool(uint32_t maxSets);
        void createDescSetLayout();
        void updateDescSets(uint32_t descSetIndex = 0);

        vk::UniqueDescriptorPool descPool;
        std::vector<vk::UniqueDescriptorSet> descSets;
        vk::UniqueDescriptorSetLayout descSetLayout;
        std::vector<vk::DescriptorSetLayoutBinding> bindings;
        std::unordered_map<vk::DescriptorType, uint32_t> descCount;
        std::vector<vk::WriteDescriptorSet> descWrites;
    };
}
